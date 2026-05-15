# CariTalent Mobile

Flutter mobile app untuk CariTalent. Versi mobile hanya mendukung 2 role: **Talent** dan **Event Organizer (EO)**. Role admin tetap ada di backend/web, tapi tidak dipakai di mobile.

## Stack

- Flutter 3.29+
- Riverpod untuk state management
- GoRouter untuk navigasi
- Dio untuk HTTP client
- Flutter Secure Storage untuk token Sanctum

## Arsitektur

```txt
lib/
  app/
    router/          # route dan mapping role
    theme/           # warna dan style global mengikuti website
  core/
    constants/       # endpoint API, role
    network/         # Dio client, exception, response envelope
    storage/         # secure token storage
    widgets/         # reusable UI components
  features/
    auth/            # login, register, session
    dashboard/       # dashboard shell Talent dan EO
    public/          # landing awal mobile
```

Reusable component awal:

- `AppShell`: background dark gradient seperti website.
- `AppCard`: translucent card dengan border putih tipis.
- `GradientText`: teks gradient highlight ke accent.
- `AppButton`: solid, outline, soft button.
- `StatCard`: kartu statistik dashboard.
- `ActionTile`: kartu quick action.
- `AppTextField`: input reusable.

## Alur Mobile

```txt
Splash
  -> cek token di secure storage
  -> GET /auth/me kalau token ada
  -> kalau role talent: masuk Talent Dashboard
  -> kalau role eo: masuk EO Dashboard
  -> kalau role admin/role lain: token dibersihkan, balik ke Home

Home
  -> Masuk
  -> Daftar

Login
  -> POST /auth/login
  -> simpan token Sanctum
  -> redirect sesuai role

Register
  -> pilih role Talent atau EO
  -> POST /auth/register
  -> simpan token Sanctum
  -> redirect sesuai role

Talent Dashboard
  -> Cari Event
  -> Lamaran
  -> Undangan
  -> Booking
  -> Review
  -> Profil

EO Dashboard
  -> Event Saya
  -> Applicant
  -> Rekomendasi
  -> Undangan
  -> Booking
  -> Profil
```

## Backend

Dokumentasi backend lokal:

```txt
http://127.0.0.1:8000/api/documentation
```

Base API:

```txt
http://127.0.0.1:8000/api/v1
```

Default app akan otomatis memilih:

| Target run | Base URL default |
|---|---|
| Android Emulator | `http://10.0.2.2:8000/api/v1` |
| Windows/Desktop/Chrome | `http://127.0.0.1:8000/api/v1` |
| Device fisik | perlu `--dart-define` pakai IP laptop |

Kalau run di device fisik, jalankan backend agar bisa diakses jaringan lokal:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Lalu run Flutter pakai IP laptop, contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

Kalau ingin override manual di emulator/desktop:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

## Credential Seeder

Sumber: `caritalentbe/database/seeders/DummyDataSeeder.php`.

Semua password:

```txt
password123
```

### EO

| Nama | Email | Password |
|---|---|---|
| Athila Ramdani Saputra | `athila@kafebraga.id` | `password123` |
| Bill Stephen Sembiring | `bill@pasarbandoeng.id` | `password123` |
| Jeany Ferliza Nayla | `jeany@bragapermai.id` | `password123` |
| Hendra Wijaya | `hendra.wijaya@gmail.com` | `password123` |

### Talent

| Nama | Email | Password |
|---|---|---|
| Muhammad Irgiansyah | `irgi@gmail.com` | `password123` |
| Arfian Ghifari Mahya | `arfian@gmail.com` | `password123` |
| Rizky Maulana | `rizky.maulana@gmail.com` | `password123` |
| Siti Nurhaliza Dewi | `siti.ndewi@gmail.com` | `password123` |
| Dendi Prasetyo | `dendi.pras@gmail.com` | `password123` |
| Fauzan Akbar Nugraha | `fauzan.akbar@gmail.com` | `password123` |
| Nandita Kusuma Wardhani | `nandita.kw@gmail.com` | `password123` |

Admin seeder `aprilianza@caritalent.id` tidak dipakai di mobile.

## Perintah

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
