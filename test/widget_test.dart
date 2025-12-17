import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pastikan import ini sesuai dengan nama project Anda di pubspec.yaml
import 'package:sekolahkita/main.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    // 1. Build aplikasi SekolahKitaApp (bukan MyApp)
    await tester.pumpWidget(const SekolahKitaApp());

    // 2. Verifikasi bahwa layar Onboarding muncul
    // Mencari teks "Selamat Datang!"
    expect(find.text('Selamat Datang!'), findsOneWidget);
    
    // Mencari teks "Mari belajar bersama"
    expect(find.text('Mari belajar bersama'), findsOneWidget);

    // 3. Verifikasi tombol "Mulai Petualangan!" ada
    expect(find.text('Mulai Petualangan!'), findsOneWidget);

    // (Opsional) Test interaksi: Masukkan nama dan tekan tombol
    // Mencari TextField
    await tester.enterText(find.byType(TextField), 'Budi');
    
    // Tap tombol mulai
    await tester.tap(find.text('Mulai Petualangan!'));
    
    // Tunggu animasi selesai (karena ada flutter_animate)
    await tester.pumpAndSettle();

    // Verifikasi sudah pindah ke HomeDashboard dan ada teks "Halo, Budi"
    expect(find.text('Halo,'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);
  });
}