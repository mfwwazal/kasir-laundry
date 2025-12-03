import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';

class ThermalPrinter {
  static final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  static Future<void> printNota({
    required String namaToko,
    required String alamat,
    required String telepon,
    required double total,
    required double bayar,
    required String tanggal,
    required String kodeTransaksi,
  }) async {
    final format = NumberFormat('#,###', 'id_ID');
    final kembalian = bayar - total;

    // CONNECT
    final isConnected = await bluetooth.isConnected ?? false;
    if (!isConnected) {
      final devices = await bluetooth.getBondedDevices();
      if (devices.isEmpty) {
        throw "Tidak ada printer yang terhubung!";
      }
      // Biasanya thermal printer namanya 'InnerPrinter', 'Bluetooth Printer'
      await bluetooth.connect(devices.first);
    }

    // START PRINT
    bluetooth.printNewLine();
    bluetooth.printCustom(namaToko, 2, 1);
    bluetooth.printCustom(alamat, 0, 1);
    bluetooth.printCustom("Telp: $telepon", 0, 1);
    bluetooth.printNewLine();

    bluetooth.printLeftRight("Tanggal", tanggal, 0);
    bluetooth.printLeftRight("Kode", kodeTransaksi, 0);
    bluetooth.printNewLine();

    bluetooth.printLeftRight("Total",
        "Rp ${format.format(total)}", 0);
    bluetooth.printLeftRight("Dibayar",
        "Rp ${format.format(bayar)}", 0);
    bluetooth.printLeftRight("Kembalian",
        "Rp ${format.format(kembalian < 0 ? 0 : kembalian)}", 0);

    bluetooth.printNewLine();
    bluetooth.printCustom("TERIMA KASIH", 1, 1);
    bluetooth.printCustom("SEMOGA HARIMU MENYENANGKAN", 0, 1);
    bluetooth.printNewLine();

    bluetooth.paperCut();
  }
}
