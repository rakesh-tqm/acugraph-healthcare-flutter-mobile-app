# 🧬 AcuGraph6

## 📘 Application Overview

AcuGraph6 is a cross-platform healthcare application developed for modern acupuncture practices. It enables practitioners to record, analyze, and generate reports based on readings from specific body points through Bluetooth-integrated acupuncture devices. The app is designed to provide visual insights, manage patient records securely, and comply with healthcare data privacy standards such as HIPAA.

## ⚙️ Tech Stack

### Frontend

* **Framework**: Flutter (Supports Android, iOS, macOS, Windows)
* **State Management**: Provider
* **Backend Communication**: RESTful API Integration
* **Authentication**: Custom API-based
* **Local Storage**: Encrypted SQLite
* **Push Notifications**: Firebase Cloud Messaging (FCM)
* **Device Integration**: BLE (Bluetooth Low Energy) for acupuncture device data capture

### Other Tools & Integrations

* **Image Upload & Compression**: `image_picker`, `flutter_image_compress`
* **PDF/Document Handling**: `flutter_pdfview`, `syncfusion_flutter_pdf`
* **Maps & Location Services**: Google Maps API, Geolocator, Custom Painter, Canvas

## 🔒 Security & Compliance

* All patient-related data is encrypted both at rest and in transit
* Full compliance with **HIPAA** standards for patient-related data
* Strict access control and data governance aligned with U.S. healthcare privacy regulations
