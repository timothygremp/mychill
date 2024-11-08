import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraModel()
    @EnvironmentObject private var onboardingManager: OnboardingManager
    
    init(onboardingManager: OnboardingManager) {
        // No need to set anything here since we're using @EnvironmentObject
    }
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()
            
            // Camera controls overlay
            VStack(spacing: 20) {
                // Top navigation bar with back button
//                HStack {
//                    // Back button
//                    Button(action: {
//                        camera.stopSession() // Stop the camera session before navigating back
//                        onboardingManager.previousStep()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.white)
//                            .font(.system(size: 24))
//                    }
//                    .padding(.leading)
//                    
//                    Spacer()
//                }
                
                // Lottie animation and app name
                VStack(spacing: 8) {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("ChillMe")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.top, -30)
                    
                }
                /*.padding(.top, -50)*/ // Move sloth higher by reducing top padding
                
                Spacer()
                
                // Bottom controls - camera shutter button
                Button(action: {
                    camera.capturePhoto { image in
                        if let image = image {
                            onboardingManager.capturedImage = image // Store the image
                            onboardingManager.nextStep() // Move to review step
                        }
                    }
                }) {
                    ZStack {
                        // Rainbow gradient inner circle
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        .red, .orange, .yellow, .green, .blue, .purple, .red
                                    ]),
                                    center: .center
                                )
                            )
                            .frame(width: 74, height: 74)
                        
                        // White outer circle
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 3)
                            .frame(width: 80, height: 80)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            camera.setupCamera()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}

class CameraModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isFlashOn = false
    @Published var showImagePicker = false
    @Published var capturedImage: UIImage?
    @Published var showReviewScreen = false
    
    private var camera: AVCaptureDevice?
    private var photoOutput = AVCapturePhotoOutput()
    private var position: AVCaptureDevice.Position = .front
    
    private var captureCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        // Run camera setup in background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.setupCamera()
        }
    }
    
    func setupCamera() {
        // Ensure we're starting fresh
        session.stopRunning()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                self.session.beginConfiguration()
                
                // Add video input
                let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: self.position)
                guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
                      self.session.canAddInput(videoDeviceInput) else { return }
                self.session.addInput(videoDeviceInput)
                
                // Add photo output
                guard self.session.canAddOutput(self.photoOutput) else { return }
                self.session.addOutput(self.photoOutput)
                
                self.session.commitConfiguration()
                
                self.session.startRunning()
            }
        }
    }
    
    // When stopping the session, also use background thread
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                if device.torchMode == .off {
                    try device.setTorchModeOn(level: 1.0)
                    isFlashOn = true
                } else {
                    device.torchMode = .off
                    isFlashOn = false
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Flash could not be used")
        }
    }
    
    func flipCamera() {
        session.beginConfiguration()
        
        // Remove existing input
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        session.removeInput(currentInput)
        
        // Switch position
        position = position == .back ? .front : .back
        
        // Add new input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                      for: .video,
                                                      position: position) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard session.canAddInput(videoDeviceInput) else { return }
        
        session.addInput(videoDeviceInput)
        session.commitConfiguration()
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        self.captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func openPhotoLibrary() {
        showImagePicker = true
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            captureCompletion?(nil)
            return
        }
        
        captureCompletion?(image)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 


