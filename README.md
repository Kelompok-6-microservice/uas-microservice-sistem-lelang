<div align="center">

  <img src="https://images.unsplash.com/photo-1555421689-491a97ff2040?q=80&w=1000&auto=format&fit=crop" alt="Auction System Banner" width="100%" height="250px" style="object-fit: cover; border-radius: 10px;">

  <br><br>

  # 🔨 UAS Microservice: Sistem Lelang (Auction System)

  **Kelompok 6 - Microservice Architecture**

  [![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![PHP](https://img.shields.io/badge/Backend-PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net/)
  [![Python](https://img.shields.io/badge/Service-Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
  [![Docker](https://img.shields.io/badge/Deployment-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](./LICENSE)

  <p>
    <b>Platform Lelang Online Terdistribusi</b> yang dibangun untuk memenuhi Tugas Akhir Semester (UAS).<br>
    Sistem ini menggunakan pendekatan <i>Microservices</i> untuk memisahkan logika bisnis, antarmuka pengguna, dan layanan notifikasi.
  </p>

  [ 📖 Documentation ](#-documentation) • [ 🚀 Installation ](#-installation-guide) • [ 👥 Contributors ](#-meet-the-team)

</div>

---

## 📑 Table of Contents

1. [📌 Overview](#-overview)
2. [🏗️ Architecture & Topography](#%EF%B8%8F-architecture--topography)
3. [🛠️ Tech Stack](#%EF%B8%8F-tech-stack)
4. [📂 Directory Structure](#-directory-structure)
5. [✨ Key Features](#-key-features)
6. [🚀 Installation Guide](#-installation-guide)
7. [🔌 API Endpoints (Preview)](#-api-endpoints-preview)
8. [👥 Meet the Team](#-meet-the-team)

---

## 📌 Overview

**Sistem Lelang Microservice** adalah aplikasi cross-platform yang memungkinkan pengguna untuk melakukan penawaran (bidding) barang secara *real-time*. Proyek ini dirancang untuk mendemonstrasikan komunikasi antar layanan menggunakan berbagai bahasa pemrograman.

Sistem ini menangani:
- **Autentikasi User** (Pembeli & Penjual).
- **Manajemen Barang Lelang** (CRUD).
- **Real-time Bidding** (Websockets).
- **Notifikasi Pemenang**.

---

## 🏗️ Architecture & Topography

Kami menggunakan arsitektur Microservices di mana Frontend (Mobile) berkomunikasi dengan beberapa layanan Backend melalui API Gateway atau langsung ke Service spesifik.

```mermaid
graph TD
    User((Mobile User))
    
    subgraph "Frontend Layer (Dart/Flutter)"
        App[Auction Mobile App]
    end
    
    subgraph "Backend Services"
        Auth[Auth Service (PHP)]
        Auction[Auction Engine (PHP)]
        Notif[Notification Service (Python)]
    end
    
    subgraph "Data Layer"
        DB1[(User DB)]
        DB2[(Auction DB)]
    end

    User <--> App
    App -- REST API --> Auth
    App -- REST API --> Auction
    Auction -- Trigger --> Notif
    Auth <--> DB1
    Auction <--> DB2
