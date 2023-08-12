# Indonesia (id)

print_already_running() {
  echo "accd sedang berjalan"
}

print_started() {
  echo "memulai accd"
}

print_stopped() {
  echo "accd berhenti"
}

print_not_running() {
  echo "accd sedang tidak berjalan"
}

print_restarted() {
  echo "memulai kembali accd"
}

print_is_running() {
  echo "accd $1 sedang berjalan $2"
}

print_config_reset() {
  echo "Mengatur ulang konfigurasi"
}

print_invalid_switch() {
  echo "Saklar pengisi daya salah, [${chargingSwitch[@]-}]"
}

print_charging_disabled_until() {
  echo "Pengisian daya di nonaktifkan sampai kapasitas baterai <= $1"
}

print_charging_disabled_for() {
  echo "Pengisian daya di nonaktifkan untuk $1"
}

print_charging_disabled() {
  echo "Pengisian daya di nonaktifkan"
}

print_charging_enabled_until() {
  echo "Pengisian daya aktif hingga kapasitas baterai >= $1"
}

print_charging_enabled_for() {
  echo "Pengisian daya aktif untuk $1"
}

print_charging_enabled() {
  echo "Pengisian daya aktif"
}

print_unplugged() {
  echo "Sambungkan pengisi daya untuk melanjutkan..."
}

print_switch_works() {
  echo "[$@] bekerja"
}

print_switch_fails() {
  echo "[$@] tidak bekerja"
}

print_no_ctrl_file() {
  echo "Tidak ditemukan file untuk mengontrol"
}

print_not_found() {
  echo "$1 tidak ditemukan"
}

print_exit() {
  echo "Keluar"
}

print_choice_prompt() {
  echo "(?) Pilih, [enter]: "
}

print_auto() {
  echo "Otomatis"
}

print_default() {
 echo "Bawaan"
}

print_curr_restored() {
  echo "Maksimal pengisian daya bawaan dipulihkan"
}

print_volt_restored() {
  echo "Maksimal voltase bawaan dipulihkan"
}

print_read_curr() {
  echo "Perlu membaca pengisian daya bawaan"
}

print_curr_set() {
  echo "Pengisian daya maksimal diatur ke $1$(print_mA)"
}

print_volt_set() {
  echo "Voltase maksimal diatur ke $1$(print_mV)"
}

print_wip() {
  echo "Opsi salah"
  echo "- Jalankan acc -h or -r untuk informasi lebih lanjut"
}

print_press_key() {
  printf "Tekan tombol apa saja untuk melanjutkan..."
}

print_lang() {
  echo "Bahasa"
}

print_doc() {
  echo "Dokumentasi"
}

print_cmds() {
  echo "Semua perintah"
}

print_re_start_daemon() {
  echo "Mulai/mulai ulang daemon"
}

print_stop_daemon() {
  echo "Hentikan daemon"
}

print_export_logs() {
  echo "Membuat log"
}

print_1shot() {
  echo "Isi daya sekali ke kapasitas tertentu (default: 100%), tanpa batasan"
}

print_charge_once() {
  echo "Mengisi daya hanya sekali ke #%"
}

print_mA() {
  echo " Milliampere"
}

print_mV() {
  echo " Millivolt"
}

print_uninstall() {
  echo "Hapus pemasangan"
}

print_edit() {
  echo "Ubah $1"
}

print_flash_zips() {
  echo "Memasang zip"
}

print_reset_bs() {
  echo "Mengatur ulang status baterai"
}

print_test_cs() {
  echo "Menguji saklar pengisian daya"
}

print_update() {
  echo "Memeriksa pembaruan"
}

print_W() {
  echo " Watt"
}

print_V() {
  echo " Voltase"
}

print_available() {
  echo "$@ sudah tersedia"
}

print_install_prompt() {
  printf "- Apakah kamu ingin mendownload dan memasangnya? ([enter]: yes, CTRL-C: no)? "
}

print_no_update() {
  echo "Tidak ada pembaruan"
}

print_A() {
  echo " Ampere"
}

print_only() {
  echo "hanya"
}

print_wait() {
  echo "Baik, ini mungkin perlu waktu beberapa menit..."
}
