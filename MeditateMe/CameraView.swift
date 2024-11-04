import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()
            
            // Camera controls overlay
            VStack {
                // Top controls
                HStack {
                    // Dismiss button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Flash toggle
                    Button(action: {
                        camera.toggleFlash()
                    }) {
                        Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                // Lottie animation and app name
                VStack(spacing: 8) {
                    LottieView(name: "sloth_10s", loopMode: .loop)
                        .frame(width: 120, height: 120)
                    
                    Text("ChillMe")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Bottom controls
                HStack(spacing: 60) {
                    // Photo library button
                    Button(action: {
                        camera.openPhotoLibrary()
                    }) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    // Camera shutter button
                    Button(action: {
                        camera.capturePhoto()
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
                    
                    // Camera flip button
                    Button(action: {
                        camera.flipCamera()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $camera.showReviewScreen) {
            if let image = camera.capturedImage {
                PhotoReviewView(selectedImage: image)
            }
        }
        .sheet(isPresented: $camera.showImagePicker) {
            ImagePicker(selectedImage: $camera.capturedImage)
        }
        .onDisappear {
            camera.stopSession()  // Stop session when view disappears
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
    
    override init() {
        super.init()
        // Run camera setup in background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.setupCamera()
        }
    }
    
    func setupCamera() {
        do {
            session.beginConfiguration()
            
            // Add video input
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: position)
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
                  session.canAddInput(videoDeviceInput) else { return }
            session.addInput(videoDeviceInput)
            
            // Add photo output
            guard session.canAddOutput(photoOutput) else { return }
            session.addOutput(photoOutput)
            
            session.commitConfiguration()
            
            // Start running in background thread
            session.startRunning()
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
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
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
              let image = UIImage(data: imageData) else { return }
        
        capturedImage = image
        showReviewScreen = true
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


