# Advanced Charging Controller (ACC)


---
- [Açıklama](#açıklama)
- [Lisans](#lisans)
- [Kullanmadan önce okuyun](#kullanmadan-önce-okuyun)
- [Uyarılar](#uyarılar)
- [Bağışlar](#bağışlar)
- [Gereksinimler](#gereksinimler)
- [Hızlı başlangıç kılavuzu](#hızlı-başlangıç-kılavuzu)
  - [Notlar](#notlar)
- [Kaynaktan indirme ve/veya kurma](#kaynaktan-indirme-veveya-kurma)
  - [(Kurulum) Gereksinimleri](#kurulum-gereksinimleri)
  - [Tarball veya zip dosyalarından kurulum](#tarball-veya-zip-dosyalarından-kurulum)
    - [Notlar](#notlar-1)
  - [Lokal kaynaktan veya GitHub'dan indir](#lokal-kaynaktan-veya-githubdan-indir)
    - [Notlar](#notlar-2)
- [Varsayılan ayarlar](#varsayılan-ayarlar)
- [Kurulum/Kullanım](#kurulumkullanım)
  - [Terminal Komutları](#terminal-komutları)
- [Pluginler](#pluginler)
- [Front end developerlar için notlar/tavsiyeler](#front-end-developerlar-için-notlartavsiyeler)
  - [Temeller](#temeller)
  - [ACC Yükleme/Güncelleme](#acc-yüklemegüncelleme)
  - [ACC Kaldırma](#acc-kaldırma)
  - [ACC Başlatma](#acc-başlatma)
  - [ACC Yönetimi](#acc-yönetimi)
  - [--info komutu](#--info-komutu)
  - [Profiller](#profiller)
  - [Daha fazla](#daha-fazla)
- [Sorun Giderme](#sorun-giderme)
  - [`acc -t` komutunun çıktıları tutarsız](#acc--t-komutunun-çıktıları-tutarsız)
  - [Batarya seviyesi doğru görünmüyor](#batarya-seviyesi-doğru-görünmüyor)
  - [Şarj portu](#şarj-portu)
  - [Özel max şarj voltaj ve akım limitleri](#özel-max-şarj-voltaj-ve-akım-limitleri)
  - [Tanı/Loglar](#tanıloglar)
  - [Hızlıca potansiyel şarj portları bulma](#hızlıca-potansiyel-şarj-portları-bulma)
  - [Yükleme, Güncelleme, çok fazla zaman alan işlemleri durdurma ve yeniden başlatma](#yükleme-güncelleme-çok-fazla-zaman-alan-işlemleri-durdurma-ve-yeniden-başlatma)
  - [Varsayılan ayarları geri yükleme](#varsayılan-ayarları-geri-yükleme)
  - [Samsung, Şarj 70% seviyede duruyor](#samsung-şarj-70-seviyede-duruyor)
  - [Yavaş şarj olma](#yavaş-şarj-olma)
  - [Şarj olmuyor](#şarj-olmuyor)
  - [Beklenmedik yeniden başlatma](#beklenmedik-yeniden-başlatma)
  - [WARP, VOOC ve Diğer hızlı şarj teknolojileri](#warp-vooc-ve-diğer-hızlı-şarj-teknolojileri)
  - [accd neden durdu?](#accd-neden-durdu)
- [Güç kaynağı logları (yardım lazım)](#güç-kaynağı-logları-yardım-lazım)
- [Lokalize etme](#lokalize-etme)
- [Tavsiyeler](#tavsiyeler)
  - [Eğer bataryanız çok eskiyse veya çok hızlı deşarj oluyorsa şarj etme akımını kısıtlayın](eğer-bataryanız-çok-eskiyse-veya-çok-hızlı-deşarj-oluyorsa-şarj-etme-akımını-kısıtlayın)
  - [Akım ve voltaj odaklı şarj kontrolü](#akım-ve-voltaj-odaklı-şarj-kontrolü)
  - [Genel](#genel)
  - [Google Pixel Cihazları](#google-pixel-cihazları)
  - [idle Mod ve Alternatifler](#idle-mod-ve-alternatifler)
- [Sıkça sorulan sorular (SSS)](#sıkça-sorulan-sorular-sss)
- [Linkler](#linkler)


---
## Açıklama

ACC [bateri ömrünü uzatma](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries) amaçlı bir Andorid yazılımıdır.
Kısaca anlatmak gerekirse, bu işlem sıcaklığı, şarj sırasında kullanılan akımı ve voltajı limitleyerek yapılır.
Herhangi bir çeşit root makuldür.
Sistem Magisk kullanılarak veya başka bir şekilde rootlanmış fark etmez, kurulum hep aynıdır.


---
## Lisans

Copyright 2017-2023, VR25

Bu ücretsiz bir yazılımdır: dilerseniz Free Software Foundation tarafından yayımlanan
GNU General Public License altında değiştirebilir veya yeniden dağıtabilirsiniz.

Bu program kullanışlu olması ümidi ile yazılmıştır,
ancak HERHANGİ BİR GARANTİSİ YOKTUR; detaylar için bkz -> GNU General Public License

Bu program aracılığı ile bu lisansın bir kopyasını edinmiş olmanız
lazım. Yoksa, bkz. <https://www.gnu.org/licenses/>.


---
## Kullanmadan önce okuyun

Bu yazılımı yüklemeden önce bu kısımı defalarca kez okuyun/yeniden okuyun.

Henüz herhangi bir cihaza zarar verilmemiş olsa da, bu yazılımın geliştiricisi yanlış kullanım sonucu oluşabilecek hiçbir şey için sorumluluk almamaktadır.
Dolandırıcılığı önlemek adına, bu proje ile bağlantılı hiçbir linki mirror(kısaltma işlemi) uygulamayın.
Farklı (tarballs/zip) buildleri PAYLAŞMAYIN! Orijinal linkleri kullanın.


---
## Uyarılar

ACC Android sistemindeki ([kernel](https://duckduckgo.com/lite/?q=kernel+android))'da şarj için sorumlu devrenin parametreleri ile oynar.
Bu yazılımın geliştiricisi yanlış kullanım sonucu oluşabilecek hiçbir şey için sorumluluk almaz.
Bu yazılımı doğru/yanlış kullanıyorsanız, bu risk size aittir!

Bazı cihazlar, özellikle Xiaomi, bug'lı bir PMIC'a (Power Management Integrated Circuit) sahipler.
Bu problem cihazın şarj olmasını engelliyor.
Bataryanızın çok düşük değerlere düşmediğinden emin olun.
acc'nin otomatik kapatma özelliğini kullanmanız şiddetle tavsiye edilir.

Ekstra detaylar için [ilgili XDA forum postu](https://forum.xda-developers.com/t/rom-official-arrowos-11-0-android-11-0-vayu-bhima.4267263/post-85119331)

[lybxlpsv](https://github.com/lybxlpsv) bootlader'dan sonra sisteme geçerek PMIC sıfırlamanızı tavsiye ediyor. (fazla teknik)


---
## Bağışlar

Lütfen bu projeyi aşağıdaki ([linkler](#linkler)'den destekleyin.
Proje büyüyüp popülerleştikçe, kahveye olan ihtiyaç artıyor :)


---
## Gereksinimler

- [Kesinlikle okunmalı - lityum iyon bataryaların ömrü nasıl uzatılır (İngilizce))](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries)
- Android veya Android temelli bir OS (işletim sistemi)
- Herhangi bir root (e.g., [Magisk](https://github.com/topjohnwu/Magisk))
- [Busybox\*](https://github.com/Magisk-Modules-Repo/busybox-ndk) (yalnızca root için Magisk kullanılmadı ise)
- Magisk kullanmayanlar acc'nin otomatik-başlamasını /data/adb/vr25/acc/service.sh, veya bir kopyasını, buna bağlı bir uzantıyı - init.d veya bunu simüle eden başka bir uygulama ile sağlayabilir.
- Terminal
- Text editor (opsiyonel)

\* Busybox binaryleri /data/adb/vr25/bin/ dizinine konabilir.
İzinler (0755), otomatik olarak ayarlanır.
Öncelik sıralaması: /data/adb/vr25/bin/busybox > Magisk's busybox > system's busybox

Diğer çalıştırılabilir veya statik binary'ler de /data/adb/vr25/bin/ dizinine (gerekli izinlerle birlikte) konabilir.


---
## Hızlı başlangıç kılavuzu


0. Bütün kodlar/aksiyonlar root gerektirir.

1. Yükleme/Güncelleme: zip dosyasından yükleyin\* veya bir front-end uygulaması kullanın.
Güncellemek için 2 yol daha mevcut: `acc --upgrade` (online) ve `acc --flash` (zip yükleyici).
Kaldırmadan/kurulumdan sonra yeniden başlatmak çoğu durumda gerekli değil.

2. [Opsiyonel] `acc` (asistan) kodunu çalıştırın. Hatırlamanız gereken tek şey bu.

3. [Opsiyonel] `acc pause_capacity resume_capacity` (varsayılan `75 70`) kodunu çalıştırıp, sırasıyla şarjın durması ve tekrardan başlaması gereken seviyeleri ayarlayın.

4. Eğer bir sorun ile karşılaşırsanız, aşağıdaki [Sorun Giderme](#sorun-giderme), [tavsiyeler](#tavsiyeler) ve [SSS](#sıkça-sorulan-sorular-sss) kısımlarına bakın.
Bir sorunu raporlamadan veya bir soru sormadan önce olabildiğince okumaya çalışın.
Çoğunlukla, sorular/cevaplar gözünüzün önünde olacak.


### Notlar

Aşama `2` ve `3` opsiyonel, çünkü varsayılan ayarlar mevcut.
Detaylar için, aşağıdaki [varsayılan ayarlar](#varsayılan-ayarlar) kısmına bakın.
Kullanıcılar için aşama `2`'nin uygulanması mevcut opsiyonlara alışmak adına şiddetle tavsiye edilir.

Ayarlar biraz fazla gibi gelebilir. Anladığınız yerden başlayın.
Varsayılan ayarlar olayı çoğunlukla toparlıyor.
Her şeyi düzenlemeniz lazımmış gibi hissetmeyin. Muhtemelen yapmamalısınız da - eğer ne yaptığınızı bilmiyorsanız.

Kaldırma: `acc --uninstall` komudunu çalıştırın veya `/data/adb/vr25/acc-data/acc-uninstaller.zip` dosyasını yükleyin\*(flashlayın).

ACC bazı 'recovery' ortamlarında da çalışıyor. (Telefonun recovery ortamı nedir bilmiyorsanız, araştırınız)
Zip tekrar yüklenmediği sürece manuel başlatma gereklidir.
Başlatma komutu `/data/adb/vr25/acc/service.sh`.


---
## Kaynaktan indirme ve/veya kurma


### (Kurulum) Gereksinimleri

- git, wget, or curl (birini seçin)
- zip


### Tarball veya zip dosyalarından kurulum

1. Kaynak kodu indirin ve gerekli dizine çıkartın: `git clone https://github.com/VR-25/acc.git`
veya `wget  https://github.com/VR-25/acc/archive/master.tar.gz -O - | tar -xz`
veya `curl -L#  https://github.com/VR-25/acc/archive/master.tar.gz | tar -xz`

2. `cd acc*`

3. `sh build.sh` (veya `build.bat` dosyasına çift click eğer Windows 10 kullanıyorsanız, veya linux içinde (zip yüklü) bir Windows alt
sistemi kullanıyorsanız)


#### Notlar

- build.sh otomatik olarak `*.sh` ve `update-binary` dosyaları içindeki `id=*` kısmını doğrular/düzeltir.
Detaylar için bkz -> framework-details.txt.
Arşiv yaratma işlemini geçmek için, kurulum script'ini rastgele bir argüman ile çalıştırın (e.g. bash build.sh h).

- Lokal kaynak kodunu güncellemek için `git pull --force` veya (wget/curl kullanara) yukarıda tanımlandığı gibi yeniden indirin.


### Lokal kaynaktan veya GitHub'dan indir

- `[export installDir=<parent install dir>] sh install.sh` çıkartılmış kaynaktan acc'yi yükler.

- `sh install-online.sh [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] [%parent install dir%] [commit]` acc'yi GitHub'dan indirip kurar - e.g., `sh install-online.sh dev`.
Argümanların sırası fark etmez.
Güncellemeler için, eğer `%parent install dir%` verilmedi ise, orijinal/var olan kullanılır.

- `sh install-tarball.sh [module id, default: acc] [parent install dir (e.g., /data/data/mattecarra.accapp/files)]` script'in lokasyonundan tarball (acc*gz) yükler.
Arşiv script ile aynı klasörde olmalı - ve GitHub'dan alınmalıdır: https://github.com/VR-25/acc/archive/$commit.tar.gz ($commit examples: master, dev, v2020.5.20-rc).


#### Notlar

- `install-online.sh`, `acc --upgrade` için bir back-end.

- Sırası ile varsayılan yükleme klasörü: `/data/data/mattecarra.accapp/files/` (ACC Uygulaması, eğer Magisk kurulu değilse), `/data/adb/modules/` (Magisk) ve `/data/adb/` (diğer root'lar için).

- Hiçbir argüman/opsiyon zorunlu değildir.
İstisna `--non-interactive` front-end uygulamalar için.

- `install-online.sh` için `--force` opsiyonu tekrar kurma veya downgrade(sürüm düşürme) içindir.

- `sh install-online.sh --changelog --non-interactive` versiyon kodunu yazdırır ve changelog(değişimler) linkini paylaşır, eğer bir güncelleme varsa.
Interaktif modda, kullanıcıya güncellemeyi indirip kurmak isteyip istemediğini de sorar.

- Aynı zamanda aşağıdaki [Terminal Komutları](#terminal-komutları) > `Çıkış Kodları` kısmını okumak yararlı olabilir.


---
## Varsayılan ayarlar
```
#DC#

configVerCode=202206010

capacity=(-1 60 70 75 false false)

temperature=(40 60 90 65)

cooldownRatio=()
cooldownCurrent=
cooldownCustom=()

resetBattStats=(false false false)

chargingSwitch=()

applyOnBoot=()

applyOnPlug=()

maxChargingCurrent=()

maxChargingVoltage=()

language=

runCmdOnPause=''

ampFactor=
voltFactor=

prioritizeBattIdleMode=false
currentWorkaround=false
battStatusWorkaround=true

schedule=''

battStatusOverride=''

rebootResume=false

: one-line script sample; echo nothing >/dev/null


# UYARILAR

# Windows Notepad ile bu dosyayı düzenlemeyin, asla!
# Dosya sonundaki (Linux/Unix) bitişini CRLF (Windows) ile değiştiriyor.

# Muhtemelen tahmin ettiğiniz üzere, varsayılan olarak "null" (boş) olan şey, boş bırakılabilir.
# "language=" ile "language=en" eşdeğerdir.
# Boş bırakılmaması gereken yerleri boş bırakmak beklenmedik durumlara yol açabilir.
# Ancak "--set var=" komutu 'var' değeri için varsayılan değeri geri yükler.
# Başka bir deyişle, normal kullanıcılar için, "--set" komutu config(ayarlar) dosyasını direkt düzenlemekten daha güvenlidir.

# Her şeyi ayarlamanız/değiştirmeniz lazım gibi düşünmeyin!
# Anlamadığınız şeyi değiştirmeyin.


# NOTES

# Bu dosyada bir değişlik yapıldıktan sonra daemon yeniden başlatılmak zorunda değilsiniz  - istisna -> 'charging_switch'.

# current_workaround (cw) değişkenine girdiğiniz yeni değerler acc yeniden başladığında aktif hale gelir (yükleme, güncelleme veya "accd --init") veya sistemi
yeniden başlatın.

# Eğer bu 2 değişken "acc --set" (acca --set değil) ile değiştirildi ise, accd otomatik yeniden başlatılır (--init komutu uygulanır, gerektiği üzere).

# Boş olarak bırakılabilecek tek değerler varsayılan(default) olarak boş halde verilenlerdir (var=, var="" and var=()).


# TEMELLER

# capacity=(shutdown_capacity cooldown_capacity resume_capacity pause_capacity capacity_sync capacity_mask)

# temperature=(cooldown_temp max_temp max_temp_pause shutdown_temp)

# cooldownRatio=(cooldown_charge cooldown_pause)

# cooldownCustom=cooldown_custom=(file raw_value charge_seconds pause_seconds)

# cooldownCurrent=cooldown_current=[milliamps]

# resetBattStats=(reset_batt_stats_on_pause reset_batt_stats_on_unplug reset_batt_stats_on_plug)

# chargingSwitch=charging_switch=(ctrl_file1 on off ctrl_file2 on off --)

# chargingSwitch=charging_switch=(milliamps)

# chargingSwitch=charging_switch=(3700-4300 millivolts)

# applyOnBoot=apply_on_boot=(ctrl_file1::value[::default] ctrl_file2::value[::default] ... --exit)

# applyOnPlug=apply_on_plug=(ctrl_file1::value[::default] ctrl_file2::value[::default] ...)

# maxChargingCurrent=max_charging_current=([value] ctrl_file1::value::default ctrl_file2::value::default ...)

# maxChargingVoltage=max_charging_voltage=([value] ctrl_file1::value::default ctrl_file2::value::default ...) --exit)

# maxChargingCurrent=max_charging_current=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...)

# maxChargingVoltage=max_charging_voltage=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...) --exit)

# language=lang=language_code

# runCmdOnPause=run_cmd_on_pause='command...'

# ampFactor=amp_factor=[multiplier]

# voltFactor=volt_factor=[multiplier]

# prioritizeBattIdleMode=prioritize_batt_idle_mode=boolean

# currentWorkaround=current_workaround=boolean

# battStatusWorkaround=batt_status_workaround=boolean

# schedule=sched='HHMM command...
# HHMM command...
# ...'

# battStatusOverride=batt_status_override=Idle|Discharging|'code to PRINT value for _status'

# rebootResume=reboot_resume=boolean


# ALIASES/SHORTCUTS

# cc cooldown_capacity
# rc resume_capacity
# pc pause_capacity
# cs capacity_sync
# cm capacity_mask

# sc shutdown_capacity
# ct cooldown_temp
# cch cooldown_charge
# cp cooldown_pause

# mt max_temp
# mtp max_temp_pause

# st shutdown_temp

# ccu cooldown_custom
# cdc cooldown_current

# rbsp reset_batt_stats_on_pause
# rbsu reset_batt_stats_on_unplug
# rbspl reset_batt_stats_on_plug

# s charging_switch

# ab apply_on_boot
# ap apply_on_plug

# mcc max_charging_current
# mcv max_charging_voltage

# l lang
# rcp run_cmd_on_pause

# af amp_factor
# vf volt_factor

# pbim prioritize_batt_idle_mode
# cw current_workaround
# bsw batt_status_workaround

# sd sched

# bso batt_status_override
# rr reboot_resume


# TAMAM DA, BÜTÜN BUNLAR NE DEMEK?

# configVerCode #
# Bu güncellemeler sırasında config(ayarlar) dosyasının değiştirilip değiştirilmemesi gerektiğini anlamak için kullanılır. Değişiklik YAPMAYIN.

# shutdown_capacity (sc) #
# Batarya deşarj oluyor ve seviyesi <= sc  değeri ise, acc daemon deşarj hızını düşürmek ve fazla düşük voltajın bataryaya verebileceği olası etkileri
azaltmak için telefonu kapatır.
# Devre dışı bırakmak için sc=-1.

# cooldown_capacity (cc) #
# Soğutma döngüsünün başlatıldığı seviyedir (cc).
# Soğutma işlemi, yüksek sıcaklık ve voltajın batarya üstüne bindirdiği yükü azaltır.
# Bunu periodik olarak şarjı birkaç saniyeliğine keserek yapar (daha fazla detay için aşağıya bakın).

# resume_capacity (rc) #
# Şarjın yeniden başlatılacağı batarya seviyesi.

# pause_capacity (pc) #
# Şarjın durdurulacağı batarya seviyesi.

# capacity_sync (cs) #
# Bazı cihazlar, özellikle Pixel sınıfından olanlar, Android ve kernel arasında batarya ile ilgili bazı tutarsızlıklara sahipler.
# capacity_sync Anroid sistemini kernel tarafından sağlanan batarya seviyesini göstermeye zorlar.
# The discrepancy is usually detected and corrected automatically by accd.
# Bu ayar otomatik davranışı yok sayar/geçersiz kılar.
# (cs.2) - Bunun yanında Android'in 2% altında değerler göstermesini engeller, bunun sebebi bazı sistemlerin kernel batarya değeri 0% olmadan önce kapanmasıdır.

# capacity_mask (cm) #
# bkz. capacity_sync.
# Bu değişken Android'i "capacity = capacity * (100 / pause_capacity)" değerini göstermeye zorlar. Uzun lafın kısası örneğin
cihazınızı şarj 70%'de dursun diye ayarladınız, şarj bu seviyeye geldiğinde sanki dolmuş (100%) gibi gösteriyor.
# bkz (cs.2) - (yukarıda)

# cooldown_temp (ct) #
# Soğutma döndüsünün (bkz. cs) (°C) başladığı sıcaklık.
# Soğutma işlemi cihazın sıcaklığını düşürerek deşarj olma hızını azaltır.
# Daha fazla bilgi için (bkz. cooldown_capacity).

# max_temp (mt) #
# mtp or max_temp_pause #
# Bu ikisi birlikte çalışırlar ve soğutma işlemi ile (bkz. cs) bağlantıları YOKTUR.
# Cihazın sıcaklığı max_temp (°C) derecesine geldiğinde, şarj 'max_temp_pause (saniye)' kadar durdurulur.
# Hem yüksek sıcaklığı hem yüksek voltajı önlemeye çalışan soğutma döngüsünün aksine - bu değişken YALNIZCA sıcaklığı
düşürmeyi amaçlar.
# Soğutma döngüsü ile direkt bağlantılı olmasa da çevre sıcaklığı çok yüksek olduğunda ona yardımcı olur.

# shutdown_temp (st) #
# Cihazı kapat, eğer sıcaklığı >= bu değer(st) ise.

# cooldown_charge (cch) #
# cooldown_pause (cp) #
# Bu ikisi soğutma döngüsünün aralıklarını (saniye) ayarlar.
# Eğer ayarlanmadılarsa, döngü devre dışı kalır.
# Tavsiye edilen değerler cch=50 ve cp=10.
# Eğer çok yavaş şarj oluyorsa, cch=50 ve cp=5 değerlerini deneyin.
# cooldown_capacity(cc) ve cooldown_temp(ct) normal koşullar altında asla ulaşılamayacak absürt değerler verilerek de etkisiz
hale getirilebilir.

# cooldown_custom (ccu) #
# Eğer cooldown_capacity ve/veya cooldown_temp ihtiyaçlarınıza uymuyorsa, bu iş görebilir.
# Varsayılan soğutma döngüsü ayarlarını yok sayar/onlardan önceliklidir.

# cooldown_current (cdc) #
# Soğutma işlemi sırasında şarj işlemini periodik olarak kesmek yerine, maksimum izin verilen şarj akımını kısıtlar(örneğin 500mA)

# reset_batt_stats_on_pause (rbsp) #
# Şarjın ardından batarya istatistiklerini sıfırlar.

# reset_batt_stats_on_unplug (rbsu) #
# Eğer şarj kablosu birkaç saniyeliğine çıkartıldı ise batarya istatistiklerini sıfırlar.

# reset_batt_stats_on_plug (rbspl) #
# Eğer şarj kablosu birkaç saniyeliğine takıldı ise batarya istatistiklerini sıfırlar.

# charging_switch (s) #
# Eğer belirtilmedi ise, acc şarjı devre dışı bırakabilen ilk portu seçer.
# Eğer port düzgün çalışmıyor ise, seçili olan portu bırakıp yukarıdaki işlemi tekrarlar.
# Eğer bütün portal şarjı devre dışı bırakma konusunda başarısız ise, chargingSwitch ayarlanmaz ve acc/d hata kodu 7 ile
çıkış yapar.
# Bu otomatik işlem "charging_switch=..." kısmının başına " --" ekleyerek devre dışı bırakılabilir.
# e.g., acc -s s="battery/charge_enabled 1 0 --"
# acc -ss komutu her zaman " --" kendisi ekler.
# charging_switch=milliamps (e.g., 0-250) şarj akım kontrolünü etkinleştirir.
# Eğer charging_switch 3700-4300 (milivolts) değerine ayarlanırsa, acc voltajı kısıtlayarak şarjı durdurur.
# Detaylar için, bkz. 'readme' dosyası /Tavsiyeler bölümü.
# Yukarıdaki orijinal varyanta kıyasla, bu otomatik olarak devre dışı kalmaz.
# Bu yüzden başına " --" koymanıza gerek yoktur.
# Bu değişken ile oynama yapıldıktan sonra daemon yeniden başlatılmalıdır (komut "acc --set").

# apply_on_boot (ab) #
# Sistem açılışında/başlangıcında uygulanan daemon kodları.
# --exit opsiyonu (bkz. applyOnBoot=...) gerekli ayarlar yapıldıktan sonra daemon modülünü durdurur.
# Eğer --exit flag opsiyonu kullanılmamış ise, daemon durduğunda varsayılan değerler tekrar yüklenir.

# apply_on_plug (ap) #
# Şarj kablosu takıldığında uygulancak olanlar
# Böyle bir değişken var çünkü /sys files (e.g., current_max) içindeki bazı değerler kablo takıldığında sıfırlanıyor.
# daemon durduğunda varsayılan değerler tekrardan yüklenir.

# max_charging_current (mcc) #
# max_charging_voltage (mcv) #
# Yalnızca akım/voltaj değeri giriniz.
# Control dosyaları otomatik olarak seçilir.

# lang (l) #
# acc dili, "acc --set --lang" (acc -sl) kullanılarak değiştirilebilir.
# Eğer null(boş) ise, English (en) yazılmış kabul edilir.

# run_cmd_on_pause (rcp) #
# Şarj durduktan sonra bir şey çalıştırın.
# * Genellikle bir script ("sh some_file" veya ". some_file")

# amp_factor (af) #
# volt_factor (vf) #
# Referans için birim çevirimi (e.g., 1V = 1000000 Microvolts)
# ACC birimi otomatik olarak algılayabilir, ancak her zaman 100% kusursuz değildir.
# e.g., eğer girilen akım değeri çok düşük ise, birim yanlış hesaplanabilir.
# Ancak nadir bir hatadır.
# Her şey düzgün çalıyorsa bu değerler ile oynamayın.

# prioritize_batt_idle_mode (pbim) #
# Eğer aktif edilirse Idle mod desteklenmesi durumunda ona öncelik verilir.
# Yalnızca charging_switch seçilmediği zaman kullanılır.
# Bu Samsung cihazlarda problem yarattığı için default(varsayılan) olarak devre dışıdır.

# current_workaround (cw) #
# Only use current control files whose paths match "batt" (default: false).
# Bu değer yalnızca şarj limitleri hem giriş hem de şarj akımını etkiliyorsa gereklidir.
# Eğer düşük akım değerleri çalışmıyor ise bunu deneyin.
# Değiştirdikten sonra "accd --init" komutu gereklidir ("acc --set" tarafından otomatize de edilebilir).

# batt_status_workaround (bsw) #
# Bu değer etkin ise, 'POWER_SUPPLY_STATUS' değerinin yanında, eğer batarya "Charging(şarj edilme)" durumunda ise ve akım değeri -11 ve 95 mA (uçlar dahil olmak üzere) aralığında ise, batarya "Idle" modda kabul edilir. Disable_charhing fonskiyonu çağırılıktan sonra, eğer akım değeri fazla düşerse, statü "Discharging(deşarj)" durumuna düşer.
# Sadece POWER_SUPPLY_STATUS değerinden alınan sonuca bağlı kalınmadığı için, bu değer uyumluluğu önemli derecede arttırır. O kadar ki, bazı cihazlarda (mesela, Nokia 2.2), acc yalnızca bu değer aktif iken çalışır.
# Öteki taraftan, cihazınız yanlış akım değerleri gösteriyorsa ve akımda fazla dalgalanma var ise şarj kontrolünde sıkıntılar yaşanabilir.
# Çoğunlukla, bu sıkıntılar adaptör kaynaklıdır.

# sched (sd) # (eğer düzenli olarak çalıştırmak istediğiniz komutlar varsa)
# Command/script schedules, in the following format:
#
# sched="HHMM command...
# HHMM command...
# ..."
#
# e.g., 3900 mV at 22:00, and 4100 mV at 6:00, daily:
# sched="2200 acc -s mcv=3900
# 0644 acc -s mcv=4100"
#
# 12 saat formatı desteklenmiyor.
# Her bir profil(schedule) kendi satırında olmalı.
# Her satır daemon tarafından işleme alınır.
# Bu acc komutlarına bağlı değildir, her şeyi çalıştırabilir.
#
# Commands:
#   -s|--set [sd|sched]="[+-]schedule to add or pattern to delete"
#     e.g.,
#       acc -s sd=-2050 (delete schedules that match 2050)
#       acc -s sd="+2200 acc -s mcv=3900 mcc=500; acc -n "Switched to \"sleep\" profile" (append schedule)
#     Not: "acc -s sd=" aynı diğer basit komutlar gibi çalışır (varsayılan değeri yükler; varsayılan değer: null, profiller için)

# batt_status_override (bso) # (Eğer kalan kısımları İngilizce anlayamıyorsanız çok bulaşmanıza gerek yok, fazlası ile teknik)
# Overrides the battery status determined by the not_charging function.
# It can be Idle, Discharging (both case sensitive), or logic to PRINT the desired value for the _status variable.
# When set to Idle or Discharging, _status will be set to that value if the enforced* charging switch state is off.
# It only works in conjunction with an enforced charging switch (set manually, has a trailing " --").
#
# Usage scenario: the switch "main/cool_mode 0 1" supports idle mode. However, sometimes it does not respond soon enough (e.g., due to fast charging). The user can then enforce it with acc -ss and set batt_status_override=Idle. This means, when main/cool_mode is on (0), _status will be determined by the not_charging function (as usual), but when it's off (1), _status will be Idle, bypassing the not_charging function.
#
# If the user were to write their own logic, it would've be something as follows:
# batt_status_override='[ $(cat main/cool_mode) -eq 1 ] && printf Idle'

# reboot_resume (rr) #
# Reboot (when capacity <= resume_capacity) to re-enable charging.
# A warning notification is posted 60 seconds prior, for the user to block the action, if they so please.

# one-line scripts #
# Every line that begins with ": " is interpreted as a one-line script.
# This feature can be useful for many things, including setting up persistent config profiles (source a file that overrides the main config).
# All script lines are executed whenever the config is loaded/sourced.
# This happens regularly while the daemon is running, and at least once per command run.
# Warning: all files used in one-line scripts must reside somewhere in /data/adb/, just like acc's own data files.

#/DC#
```

---
## Kurulum/Kullanım


Yukarıdaki [varsayılan ayarlar](#varsayılan-ayarlar)'da da bahsediliği üzere, ACC kutusu açılır açılmaz çalışması için tasarlandı, çok minik
veya hiç değişim olmadan.

Hatırlamanız gereken tek komut `acc`.
Ya tamamen seveceğiniz ya da tamamen nefret edeceğinizi bir asistan.

Terminal kullanmaktan rahatsız oluyorsanız, bu kısmı atlayın ve bir fron-end app kullanın.

Alternatif olarak, `/data/adb/vr25/acc-data/config.txt` dosyasını düzenlemek için bir `text editor` kullanabilirsiniz.
Ayarlar(config) dosyası içinde aynı zamanda yönergeler barındırıyor.
Bunlar yukarıda [varsayılan ayarlar](#varsayılan-ayarlar) kısmında bulunanlar ile aynı.


### Terminal Komutları
```
#TC#

Kullanım

  acc    Asistan

  accd   accd başlat/yeniden başlat

  accd.  acc/daemon durdur

  accd,  acc/daemon durumunu yazdır (çalışıyor veya çalışmıyor)

  acc [pause_capacity/millivolts [resume_capacity/millivolts, varsayılan: pause_capacity/millivolts - 5%/50mV]]
    e.g.,
      acc 75 70
      acc 80 (resume_capacity 80% - 5 yapılır)
      acc 3900 (acc 3900 3870 ile aynı, idle mod için alternatif)

  acc [options] [args]   Opsiyonlar listesi için aşağıya bakın

  acca [options] [args]   front-end için acca

  acc[d] -x [options] [args]   Sets log=/sdcard/Download/acc[d]-\${device}.log; istenmeyen reboot durumlarında debug(hata ayıklama) için kullanışlı

  İlk parametre yerine özel bir ayar dosyası dizini belirtilebilir (eğer -x kullanıldı ise ikinci parametre).
  Eğer böyle bir dosya yoksa, mevcut ayarlar kopyalanır.
    e.g.,
      acc /data/acc-night-config.txt --set pause_capacity=45 resume_capacity=43
      acc /data/acc-night-config.txt --set --current 500
      accd /data/acc-night-config.txt --init

  accd için notlar:
    - "--init|-i" sıralaması önemli değil.
    - Ayar dosyası dizini "--init|-i" içermemeli.


Options

  -b|--rollback   Güncellemeyi geri al

  -c|--config [editor] [editor_opts]   Ayarları düzenle (varsayılan editör: nano/vim/vi)
    e.g.,
      acc -c (nano/vim/vi kullanarak düzenle)
      acc -c less
      acc -c cat

  -d|--disable [#%, #s, #m or #h (optional)]   Şarjı devre dışı bırak
    e.g.,
      acc -d 70% (şarj seviyesi <= 70% olana kadar şarj etme)
      acc -d 1h (1 saat boyunca şarj etme)

  -D|--daemon   daemon durumunu yazdır, (eğer çalışıyorsa) versiyon ve PID
    e.g., acc -D (namıdiğer: "accd,")

  -D|--daemon [start|stop|restart]   daemon kontrolü
    e.g.,
      acc -D start (namıdiğer: accd)
      acc -D restart (namıdiğer: accd)
      accd -D stop (namıdiğer: "accd.")

  -e|--enable [#%, #s, #m or #h (optional)]   Şarjı aktif et
    e.g.,
      acc -e 75% (75%'e kadar şarj et)
      acc -e 30m (30 dakika şarj et)

  -f|--force|--full [capacity]   Bir kereliğine verilen seviyeye kadar şarj et (varsayılan: 100%), kısıtlamalar olmadan
    e.g.,
      acc -f 95 (95%'e kadar şarj et)
      acc -f (100%'e kadar şarj et)
    Note: Eğer istediğiniz seviye [pause_capacity]'den küçükse, acc -e #% kullanın

  -F|--flash ["zip_file"]   update-binary olarak shell-script kullanan herhangi bir zip dosyası yükle
    e.g.,
      acc -F (zip yükleme asistanını başlatır)
      acc -F "file1" "file2" "fileN" ... (birden fazla zip yükle)
      acc -F "/sdcard/Download/Magisk-v20.0(20000).zip"

  -i|--info [case insensitive egrep regex (default: ".")]   Batarya bilgisini göster
    e.g.,
      acc -i
      acc -i volt
      acc -i 'volt\|curr'

  -l|--log [-a|--acc] [editor] [editor_opts]   accd log yazdır/düzenle (varsayılan) veya acc log (-a|--acc)
    e.g.,
      acc -l (acc -l less ile aynı)
      acc -l rm
      acc -l -a cat
      acc -l grep ': ' (bariz hataları göster)

  -la   Same as -l -a

  -l|--log -e|--export   Bütün logları /sdcard/Download/acc-logs-$deviceName.tgz dizinine çıkart
    e.g., acc -l -e

  -le   Same as -l -e

  -n|--notif [["STRING" (default: ":)")] [USER ID (default: 2000 (shell))]]   Android bildirimi; her sistemde çalışmayabilir
    e.g., acc -n "Hello, World!"

  -p|--parse [<base file> <file to parse>] | <file to parse>]   Şarj portlarını hızlıca bulmaya yardımcı olur, herhangi bir cihaz için
    e.g.,
      acc -p   $dataDir/logs/power_supply-\*.log oluştur $TMPDIR/ch-switches içinde olmayan şarj portlarını yazdır
      acc -p /sdcard/power_supply-harpia.log verilen dizini oluştur ve $TMPDIR/ch-switches içinde olmayan şarj portlarını yazdır
      acc -p /sdcard/charging-switches.txt /sdcard/power_supply-harpia.log  /sdcard/power_supply-harpia.log dizinini oluştur ve /sdcard/charging-switches.txt içinde olmayan şarj portlarını yazdır

  -r|--readme [editor] [editor_opts]   Yazdır/düzenle README.md
    e.g.,
      acc -r (same as acc -r less)
      acc -r cat

  -R|--resetbs   Batarya istatistiklerini sıfırla
    e.g., acc -R

  -s|--set   Kullanılan ayarları yazdır
    e.g., acc -s

  -s|--set prop1=value "prop2=value1 value2"   [birden fazla] özellik ayarla
    e.g.,
      acc -s charging_switch=
      acc -s pause_capacity=60 resume_capacity=55 (kısayollar: acc -s pc=60 rc=55, acc 60 55)
      acc -s "charging_switch=battery/charging_enabled 1 0" resume_capacity=55 pause_capacity=60
    Not: her şeyin hızlıca yazmak için bir kısayolu var; görmek için "acc -c cat"

  -s|--set [sd|sched]="[+-]profil ayarlar veya kaldır"
    e.g.,
      acc -s sd=-2050 (2050 ile eşleşenleri kaldır)
      acc -s sd="+2200 acc -s mcv=3900 mcc=500; acc -n "Switched to \"sleep\" profile" (append schedule)
    Not: "acc -s sd=" aynı diğer basit komutlar gibi çalışır (varsayılan değeri yükler; varsayılan değer: null, profiller için)

  -s|--set c|--current [milliamps|-]   Maksimum şarj akımı ayarla/yazdır/varsayılana döndür (aralık: 0-9999$(print_mA))
    e.g.,
      acc -s c (şu anki limiti yazdır)
      acc -s c 500 (ayarla)
      acc -s c - (varsayılana döndür)

  -sc [milliamps|-]   Yukarıdaki ile aynı

  -s|--set l|--lang   Dil değiştir
    e.g., acc -s l

  -sl   Yukarıdaki ile aynı

  -s|--set d|--print-default [egrep regex (default: ".")]   Varsayılan ayaları yazdır, boşluk olmadan
    e.g.,
      acc -s d (bütün varsayılan ayarları yazdır)
      acc -s d cap (yalnızca "cap" ile eşleşen girdileri yazdır)

  -sd [egrep regex (default: ".")]   Yukarıdaki ile aynı

  -s|--set p|--print [egrep regex (default: ".")]   Varsayılan ayaları yazdır, boşluk olmadan (önceki örneklere bakın)

  -sp [egrep regex (default: ".")]   Yukarıdaki ile aynı

  -s|--set r|--reset [a]   Varsayılan ayaları yükle ("a", "all" tamamı için: ayar ve kontrol dosyaları, kökten bir sıfırlama)
    e.g.,
      acc -s r

  -sr [a]   Yukarıdaki ile aynı


  -s|--set s|charging_switch   Bir şarj portunu seç
    e.g., acc -s s

  -ss    Yukarıdaki ile aynı

  -s|--set s:|chargingSwitch:   Bilinen şarj portlarını listele
    e.g., acc -s s:

  -ss:   Yukarıdaki ile aynı

  -s|--set v|--voltage [millivolts|-] [--exit]   Maksimum şarj voltajı ayarla/yazdır/varsayılana döndür (range: 3700-4300$(print_mV))
    e.g.,
      acc -s v (yazdır)
      acc -s v 3900 (ayarla)
      acc -s v - (varsayılana döndür)
      acc -s v 3900 --exit (ayaları uyguladıktan sonra daemon durdur)

  -sv [millivolts|-] [--exit]   Yukarıdaki ile aynı

  -t|--test [ctrl_file1 on off [ctrl_file2 on off]]   Özel şarj portlarını test et
    e.g.,
      acc -t battery/charging_enabled 1 0
      acc -t /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" yerini tutar -> " " - MTK only)

  -t|--test [file]   Bir dosyadaki şarj portlarını test et (varsayılan: $TMPDIR/ch-switches)
    e.g.,
      acc -t (bilinen portları test et)
      acc -t /sdcard/experimental_switches.txt (özel/bilinmeyen portları test et)

  -t|--test [p|parse]   Potansiyel şarj portlarını güç kaynağı loglarından (aynı "acc -p" gibi) al, hepsini test et, ve çalışanları bilinen portlar
listesine ekle
    Implies -x, as acc -x -t p
    e.g., acc -t p

  -T|--logtail   accd loglarını görüntüle (tail -F)
    e.g., acc -T

  -u|--upgrade [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive]   Online güncelleme/sürüm düşürme
    e.g.,
      acc -u dev (en son versiyona güncelle)
      acc -u (bulunulan (branch)'teki son versiyona güncelle)
      acc -u master^1 -f (bir önceki versiyon)
      acc -u -f dev^2 (iki versiyon öncesi)
      acc -u v2020.4.8-beta --force (güncelleme/sürümü düşürmeyi zorla -> v2020.4.8-beta)
      acc -u -c -n (eğer güncelleme varsa, versiyon numarasını yazdır ve changelog(değişimler) linkini göster)
      acc -u -c (same as above, but with install prompt)

  -U|--uninstall   acc ve AccA 'yı tamamen kaldır
    e.g., acc -U

  -v|--version   acc versiyon ve versiyon kodunu yazdır
    e.g., acc -v

  -w#|--watch#   Bataryada olanları izle/görüntüle
    e.g.,
      acc -w (her 3 saniyede bir güncelle)
      acc -w0.5 (her yarım saniyede bir güncelle)
      acc -w0 (eksta gecikme yok)


Çıkış kodları

  0. Doğru/başaarılı
  1. Yanlış/genel olarak hatalı
  2. Yanlış syntax
  3. Eksik busybox binary
  4. root olarak çalışmıyor
  5. Güncelleme mevcut ("--upgrade")
  6. Güncelleme yok ("--upgrade")
  7. Şarjı devre dışı bırakılamadı.
  8. Daemon zaten çalışıyor ("--daemon start")
  9. Daemon çalışmıyor ("--daemon" and "--daemon stop")
  10. Hiçbir şarj portu çalışmıyor (--test)
  11. 0-9999 aralığından akım (mA)
  12. Başlatma işlemi başarısız
  13. $TMPDIR/acc.lock kitlenemedi
  14. ACC başlatılamadı, çünkü Magisk module 'disable flag' aktif durumda
  15. Idle mod destekleniyor (--test)
  16. Şarj aktif etme işlemi başarısız (--test)

  Loglar ("--log --export") çıkış kodları 1,2 ve 7'de otomatik olark yazdırılır


Tavsiyeler

  Komutlar kolaylık olması açısından arka arkaya sıralanabilir.
    e.g., 30 dakika şarj et, 6 saat şarj etmeyi durdur, 85% seviyesine kadar şarj et ve daemon yeniden başlat
    acc -e 30m && acc -d 6h && acc -e 85 && accd

  Basit bir profil
    acc -s pc=60 rc=55 mcc=500 mcv=3900
      Şarj seviyesi 55-60% arasında tutulur, akım 500 mA ve voltaj 3900 milivolt ile sınırlanır.
      Gece vakti "sürekli-şarjda" durumları için ideal.

  Bütün bilgiler için acc -r (veya --readme) kodlarını çalıştırın (önerilir)

#/TC#
```

---
## Pluginler

Those are scripts that override functions and some global variables.
They should be placed in `/data/adb/vr25/acc-data/plugins/`.
Files are sorted and sourced.
Filenames shall not contain spaces.
Hidden files and those without the `.sh` extension are ignored.

There are also _volatile_ plugins (gone on reboot, useful for debugging): `/dev/.vr25/acc/plugins/`.
Those override the permanent.

A daemon restart is required to load new/modified plugins.


---
## Front end developerlar için notlar/tavsiyeler

### Temeller

ACC does not require Magisk.
Any root solution is fine.

Use `/dev/.vr25/acc/acca` instead of regular `acc`.
It's optimized for front-ends, guaranteed to be readily available after installation/upgrades and significantly faster than its `acc` counterpart.
`acca --set prop1=bla prop2="bla bla" ...` runs asynchronously (non-blocking mode) - meaning, multiple instances of it work in parallel.

It may be best to use long options over short equivalents - e.g., `--set charging_switch=` instead of `-s s=`.
This makes code more readable (less cryptic).

Include provided descriptions of ACC features/settings in your app(s).
Provide additional information (trusted) where appropriate.
Explain settings/concepts as clearly and with as few words as possible.

Take advantage of exit codes.
Refer back to `Kurulum/Kullanım > [Terminal Komutları](##terminal-komutları) > Çıkış Kodları`.


### ACC Yükleme/Güncelleme

This should be trivial.
The simplest way is flashing acc from Magisk manager.

Alternatively, `install.sh`, `install-online.sh` or `install-tarball.sh` can be used.
For details, refer back to [install from local source or GitHub](#install-from-local-source-or-github).

Developers can also use the _updateJSON_ API.
The front-end downloads and parses [this JSON file](https://raw.githubusercontent.com/VR-25/acc/master/module.json).
The format is as follows:

```
{
    "busybox": "https://github.com/Magisk-Modules-Repo/busybox-ndk",
    "changelog": "https://raw.githubusercontent.com/VR-25/acc/master/changelog.md",
    "curl": "https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/tree/master/curl",
    "tgz": "https://github.com/VR-25/acc/releases/download/$version/acc_${version}_${versionCode}.tgz",
    "tgzInstaller": "https://github.com/VR-25/acc/releases/download/$version/install-tarball.sh",
    "version": "STRING",
    "versionCode": INT,
    "zipUrl": "https://github.com/VR-25/acc/releases/download/$version/acc_${version}_${versionCode}.zip"
}
```

### ACC Kaldırma

`/dev/.vr25/acc/uninstall` dosyasını çalıştırın (yeniden başlatmaya gerek yok; **şarj kablosu takılı olmalı**) veya Magisk üzerinden kaldırıp cihazı yeniden başlatın.


### ACC Başlatma

On boot_completed receiver and main activity, run:

`[ -f /dev/.vr25/acc/acca ] || /data/adb/vr25/acc/service.sh`

Explanation:

ACC's working environment must be initialized - i.e., by updating the stock charging config (for restoring without a reboot) and pre-processing data for greater efficiency.
This is done exactly once after boot.
If it were done only after installation/upgrade, one would have to reinstall/upgrade acc after every kernel update.
That's because kernel updates often change the default power supply drivers settings.

Since acc's core executables are dynamic ([expected to] change regularly), those are linked to `/dev/.vr25/acc/` to preserve the API.
The links must be recreated once after boot (/dev/ is volatile).

`accd` is a symbolic link to `service.sh`.
If service.sh is executed every time the `main activity` is launched, accd will be repeatedly restarted for no reason.

Notes

- This "manual" initialization is only _strictly_ required if Magisk is not installed - and only once per boot session. In other words, Magisk already runs service.sh shortly after boot.
- ACC's installer always initializes it.


### ACC Yönetimi

As already stated, front-ends should use the executable `/dev/.vr25/acc/acca`.
Refer to the [default configuration](#varsayılan-ayarlar) and [terminal commands](#terminal-commands) sections above.

The default config reference has a section entitled variable aliases/shortcuts.
Use ONLY those with `/dev/.vr25/acc/acca --set`!

To clarify, `/dev/.vr25/acc/acca --set chargingSwitch=...` is not supported!
Use either `s` or `charging_switch`.
`chargingSwitch` and all the other "camelcase" style variables are for internal use only (i.e., private API).

Do not parse the config file directly.
Use `--set --print` and `--set --print-default`.
Refer back to [terminal commands](#terminal-commands) for details.


### --info komutu

Bu komut 'kernel' tarafından sağlanır, acc ile bağlantılı değildir.
Bazı kernal'lar diğerlerinden daha fazla bilgi verebilir.

Çıktının çoğunluğu gereksizdir (veya güvenilemez bilgi içerir (örn. , health, speed).

Odaklanmanız gerekenler şunlardır:

STATUS=Charging # Charging, Discharging or Idle
CAPACITY=50 # Battery level, 0-100
TEMP=281 # Always in (ºC * 10)
CURRENT_NOW=0 # Charging current (Amps)
VOLTAGE_NOW=3.861 # Charging voltage (Volts)
POWER_NOW=0 # (CURRENT_NOW * VOLTAGE_NOW) (Watts)

Güç bilgisi bataryaya sağlanan değeri gösterir, adaptör tarafından iletilen değeri değil.
Harici kaynaklardan gelen güç bataryaya ulaşmadan önce her zaman dönüştürülür.


### Profiller

Those are simply different config files.
A config path can be supplied as first argument to `acca` and second to `accd` executables.

Examples:

_Copy the config:_

Current config: `/dev/.vr25/acc/acca --config cat > /path/to/new/file`

Default config: `/dev/.vr25/acc/acca /path/to/new/file --version` (`--version` can be replaced with any option + arguments, as seen below.)

_Edit the copy:_

`/dev/.vr25/acc/acca /path/to/new/file --set pause_capacity=75 resume_capacity=70` (if the file does not exist, it is created as a copy of the default config.)

_Use the copy:_

`/dev/.vr25/acc/accd --init /path/to/new/file` (the daemon is restarted with the new config.)

_Back to the main config:_

`/dev/.vr25/acc/accd --init`


### Daha fazla

Config üzerinde oynama yapıldıktan sonra ACC daemon yeniden başlatılmak zorunda değildir.
Değişiklikleri birkaç saniye içinde görür.

Bazı istisnalar şunlardır:

- `charging_switch` (`s`) requires a daemon restart (`/dev/.vr25/acc/accd`).
- `current_workaround` (`cw`) requires a full re-initialization (`/dev/.vr25/acc/accd --init`).

Bu bilgi aynı zamanda [varsayılan ayarlar](#varsayılan-ayarlar) kısmında da mevcuttur.


---
## Sorun Giderme


## acc -t komutunun çıktıları tutarsız

"varsayılan ayarlar > batt_status_workaround" kısmına bakın.


### Batarya seviyesi doğru görünmüyor

Android'teki batarya seviyesi kernel'dakinden farklı ise, ACC daemon otomatik olarak yenilenir ve batarya servisini durdurarak birkaç saniyede bir
gerçek değeri kullandırtır.

Uzun süredir Pixel cihazları bataryadaki tutarsızlıkları ile biliniyorlar.

Eğer cihazınız bataryanız daha tamamen boşalmadan kapanıyorsa, capacity_sync veya capacity_mask yardımcı olabilir.
Detaylar için yukarıdaki [varsayılan ayarlar](#varsayılan-ayarlar) kısmına bakınız.


### Şarj portu

Fabrika ayalarında, ACC çalışan herhangi bir [charging switch](https://github.com/VR-25/acc/blob/dev/acc/charging-switches.txt) (şarj portu) kullanır. Ancak, işler her zaman düzgün gitmeyebiliyor.

- Bazı portlar spesifik koşullar altında çalışmaz (e.g., mesela ekran kapalı iken).

- Bazılarında bir [wakelock](https://duckduckgo.com/lite/?q=wakelock) mevcuttur.
Bu, şarj işlemi durduktan sonra cihazın hızlı deşarj olmasına neden olur.

- Sistem tarafından aktif edilen şarj işlemi, ACC tarafından birkaç saniye sonra kapatılıyor.
Bunun bir sonucu olarak, batarya eninde sonunda %100 şarja ulaşıyor, pause_capacity (şarj durma seviyesi) ne olursa olsun.

- Yüksek CPU kullanımı (batarya kullanımı) aynı zamanda tarafımıza raporlandı.

- En kötü senaryoda, batarya durumu `discharging` (şarj olmuyor), şeklinde gösterilirken `charging` (şarj edilme) durumunda oluyor.

Bu tarz durumlarda çalışan bir port seçmelisiniz.
İşte nasıl yapılacağı:

1. Hangi portların çalıştığını öğrenmek için `acc --test` (veya `acc -t`)komutunu çalıştırın.
2. Portlardan birini seçmek/ayarlamak için `acc --set charging_switch` (veya `acc -ss`) komutlarını kullanın.
3. Portun güvenilirliğini kontrol edin. Eğer çalışmıyorsa, başkasını deneyin.

Herkes aynı teknik beceriye sahip olmadığı için, ACC bazı cihazlarda şarj portu problemlerini azaltmak için modele özel ayarlar uyguluyor.
bkz. `acc/oem-custom.sh`.


### Özel max şarj voltaj ve akım limitleri

Maalesef, bütün kernal'lar bunu desteklemiyor.
Akım limitleri çoğu kernel tarafından desteklense de (en azından bir düzeye kadar), voltaj değiştirme desteği _fazlasıyla_ nadir.

Bununla birlikte, voltaj üzerinden oynama yapmanıza izin tanıyan kontrol dosyalarının var olması bunların kernel'a her zaman işlenebileceği anlamına gelmiyor.

\* Root yeterli değil.
Kernel düzeyi izinler bazı şeylerin yazılmasına engel olabiliyor.

Bazen, varsayılan ayarların yüklenmesi sistemi yeniden başlatmadan mümkün olmayabilir.
Bunun bir çözümü maksimum akım değerini gereksiz yüksek bir değere eşitlemektir (e.g., 9000 mA).
Cihazını yakma korkunuz falan olmasın.
Telefon alabildiği maksimum değeri alacaktır.

**UYARI**: voltaj limitleri bazı cihazlarda batarya seviyesinin yansımasına dair problemler yaratabilir.
Ancak, batarya bakım sistemi kendi kendisini sürekli doğrultuyor.
Bu yüzden, eski varsayılan hale döndürüldüğünde kendini yavaş yavaş düzeltmeye başlayacaktır.

Öte yandan. akımı limitlemek evrensel olarak güvenli gibi görünüyor.
Bazı cihazlar her değeri sağlamayabilir.
Bu yüksek değerler problem yaratır demek değildir ancak.
Onlar kısaca görmezden gelinir.

Eğer düşük akım değerleri işe yaramıyor ise `current_workaround=true` değişkenini deneyebilirsiniz (`accd --init` komutundan sonra çalışır.)
Detaylar için [varsayılan ayarlar](#varsayılan-ayarlar) kısmına bakınız.

Varsayılan şarj voltaj/akımlarını `acc/ctrl-files.sh` dosyasını `/data/adb/vr25/acc-data/plugins/` dizinine kopyalayıp gerekli değişimleri yaparak kendi ayarlarınızı dikte edebilirsiniz.
Bunda önce varsayılan limitlere geri dönülmesi gerektiğini not edelim, aksi takdirde sistemin reboot(yeniden başlatması) gerekecektir.
Hatırlatma: yeni/değiştirilmiş pluginlerin yüklenmesi için daemon başlamalıdır.


### Tanı/Loglar

Yeniden başlatınca giden (geçici) loglar `/dev/.vr25/acc/` dizininde bulunur (yalnızca .log uzantılı dosyalar).
Kalıcı loglar `/data/adb/vr25/acc-data/logs/` adresindedir.

`acc -le` komutu bütün acc ve Magisk ile alakalı logları gösterir, `/data/adb/acc-data/logs/acc-$device_codename.tgz` dizinine bakınız.
Loglar kişisel veri içermez ve geliştiriciye otomatik olarak gönderilmez.
Otomatik raporlama yalnızca belirli koşullar altında gerçekleşir (bkz. `Kurulum/Kullanım > Terminal Komutları > Çıkış Kodları`).


### Yükleme, Güncelleme, çok fazla zaman alan işlemleri durdurma ve yeniden başlatma

Daemon durdurma işleminde şarj yönetim sisteminde yapılan değişiklikler geri alınır.
Bazen, **şarj kablosunun takılması gerekebilir**.
Bunun sebebi bazı kernel'ların sorunlu olması veya şarj devrelerinin çok iyi çalışmamasıdır.
Bu gibi durumlarda accd restorasyon işlemi için durdurulur.
Eğer ne yaptığınızı biliyorsunuz `pkill -9 -f accd` komutu da kullanılabilir.


### Kernel Panic and Spontaneous Reboots

Buna neden olan kontrol dosyaları otomatik olarak kara listeye alınır (bkz. `/data/adb/acc-data/logs/write.log`).


### Varsayılan ayarları geri yükleme

Bu fazlası ile zaman kazandırabilir.

`acc --set --reset`, `acc -sr` veya `rm /data/adb/vr25/acc-data/config.txt` (failsafe)


### Samsung, Şarj 70% seviyede duruyor

Bu cihaza özel bir problem (tercih olarak?).
Sebebi _store_mode_ şarj kontrol dosyası.
Engellemek için  _batt_slate_mode_ değişkeninin aktifleştirin.
Daha detaylı bilgi için [şarjı portu](#şarj-portu) kısmına göz atın.


### Yavaş şarj olma

Aşağıdakilerden en az biri bir sebep olabilir:

- Şarj akımı ve/veya voltaj limitleri
- Soğutma döngüsü (optimal olmayan şarj et/dur oranı, 50/10 veya 50/5 deneyin)
- Sorunlu şarj portu (bkz. `Sorun Giderme > Şarj Portu`)
- Yetersiz adaptör ve/veya güç kardı


### şarj olmuyor

bkz. [Uyarılar](#uyarılar) kısmı.


### Beklenmedik yeniden başlatma

Yalnış şarj kontrol dosyaları istenmedik durumlara yol açabilir.
ACC bunları otomatik olarak kara listeye alır (`/data/adb/vr25/acc-data/logs/write.log` dizininde bulunabilir).
Bazen, yanlışlıkla karalisteye düşenler olabilir - başka bir deyişle, beklenmedik yeniden başlatmaya sebep olan ikinci bir sebepten ötürü. Eğer daha önce çalışan bir kontrol dosyası bir anda çalışmamaya başladı ise, kara listede olup olmadığını kontrol edin (`acc -t` aynı zamanda kara listedeki portları da gösterir).
Yeniden başlatma işlemi durduğunda `write.log` dosyasını geliştiriciye gönderin.


### WARP, VOOC ve Diğer hızlı şarj teknolojileri

Şarj portları orijinal güç adaptörleriniz ile düzgün çalışmayabilir.
Bu acc nedeni ile oluşan bir sıkıntı değildir.
Bu telefon üreticinizden kaynaklı bir sorundur.
Böyle sorunlar ile karşılaşıyorsanız, başka bir şarj portu deneyin veya hızlı şarj desteklemeyen bir şarj adaptörü kullanın.
Şarj olma akım/voltaj kısıtlamalarını da deneyebilirsiniz.


### accd neden durdu?

Nedenini bulmak için `acc -l tail` komudunu çalıştırın.
Bu daemon log dosyasının son 10 satırını yazdırır.

Fazlasıyla yaygın bir çıkış kodu `7` - bütün portlar şarjı devre dışı bırakmakta başarısız oldu anlamına geliyor.
Bu kernel ile alaklı bir sorunlardan ötürü gerçekleşiyor (bundan önceki kısma bkz. - [şarj portu](#şarj-portu)).
Eğer daemon çalışan portu otomatik olarak kurmaya ayarlı ise (varsayılan ayar), bunun sonucu olarak durabilir.
Manuel olarak `acc -ss` veya `acc -s s="PORTLAR BURAYA YAZILIYOR --"` komutları ile bir port belirlemek accd'nin otomatik olarak devre dışı kalmasını bu durumda önler.


---
## Güç kaynağı logları (yardım lazım)

Lütfen `acc -le` komudunu çalıştırıp `/data/adb/vr25/acc-data/logs/power_supply-*.log` dizinindeki çıktıyı [dropbox](https://www.dropbox.com/request/WYVDyCc0GkKQ8U5mLNlH) linkine yükleyin (herhangi bir hesap oluşturmanız gerekli değil).
Bu dosya değeri ölçülmez düzeyde güç kaynağı hakkında bilgi içeriyor, batarya detayları ve mevcut şarj yöntemleri gibi.
Karşılıklı yarar sağlanması adına halka açık bir database oluşturuluyor.
Yardımınız fazlası ile takdir görecektir.

Gizlilik notları

- İsim: rastgele/sahte
- İsim: rastgele/sahte

Yapılmış yüklemeleri [buradan](https://www.dropbox.com/sh/rolzxvqxtdkfvfa/AABceZM3BBUHUykBqOW-0DYIa?dl=0) görüntüleyin.


---
## Lokalize etme


Currently Supported Languages and Translation Levels (full, good, fair, minimal)

- Chinese, simplified (zh-rCN): minimal
- Chinese, traditional (zh-rTW): minimal
- English (en): full
- German (de_DE): fair
- Indonesia (id): minimal
- Portuguese, Portugal (pt-PT): minimal


Translation Notes

1. Start with copies of [acc/strings.sh](https://github.com/VR-25/acc/blob/dev/acc/strings.sh) and, optionally, [README.md](https://github.com/VR-25/acc/blob/dev/README.md).

2. Modify the header of strings.sh to reflect the translation (e.g., # Español (es)).

3. Anyone is free and encouraged to open translation [pull requests](https://duckduckgo.com/lite/?q=pull+request).
Alternatively, a _compressed_ archive of translated `strings.sh` and `README.md` files can be sent to the developer via Telegram (link below).

4. Use `acc -sl` (--set --lang): language switching wizard or `acc -s l=<lang_string>` to set a language.


---
## Tavsiyeler


### Eğer bataryanız çok eskiyse veya çok hızlı deşarj oluyorsa şarj etme akımını kısıtlayın

Bu, bataryanın total hayatını olumlu etkiler ve hatta _deşarj_ olma hızını bile azaltabilir.

750-1000mA aralığı gündelik kullanım için uygundur.

500mA kabul edilebilir bir minimum - aynı zamanda oldukça uyumlu.

Eğer cihazınız akım limitlemeyi desteklemiyor ise, ("yavaş") şarj eden bir adaptör kullanın.


### Akım ve voltaj odaklı şarj kontrolü

charging_switch=milliamps veya charging_switch=3700-4300 (millivolts) değişkenlerini ayarlayarak aktive edilir (e.g., `acc -s s=0`, `acc -s s=250`, `acc -s s=3700`, `acc -ss` (asistan)).

Sonuç olarak bu işlem voltaj/akım kontrol dosyalarını _[sahte] şarj portları_'na dönüştürür.

Bunun yaygın ve pozitif bir yan etkisi ise _[sahte] idle mod_ 'dur - i.e., batarya bir çeşit power buffer gibi çalışır.

Not: kernel'a bağlı olarak - `pause_capacity`(durma seviyesinde), şarj statüsü değişebilir veya ("deşarj" veya "şarj olmuyor") veya sabit kalabilir ("şarj ediliyor" - bir problem değil).
Aralıklı olarak değişiyorsa, akım çok az demektir; problem çözülene kadar arttırın.


### Genel

 _batarya idle mod_ 'unu bir voltaj limiti ile taklit edin: `acc -s pc=101 rc=0 mcv=3900`.
İlk iki argüman şarj başlama/durma fonksiyonunu devre dışı bırakıyor.
Son olan da bataryanın ne derecede dolacağını ayarlayan bir voltaj dikte ediyor.
Batarya, voltaj yükseldiğinde bir _[sahte] idle mod_ 'a giriyor.
Sonuç olarak, bir power buffer gibi çalışıyor.

Benzer bir etki `acc 60 59` (yüzdeler) ve `acc 3900` (milivolt) komutları ile de elde edilebilir.

Başka bir yol ise şarj akımını 0-250 mA aaralığına hapsetmek veya (e.g., `acc -sc 0`).
`acc -sc -` varsayılan(fabiraka ayarı) limiti yeniden yükler.
Alternatif olarak, `acc -s s=0` ve/veya `acc -s s=3700`komutlarını test edebilirsiniz, bunlar şarj/voltaj kontrol dosyalarını bir şarj portu gibi kullanırlar.

Hızlı şarja zorla: `appy_on_boot="/sys/kernel/fast_charge/force_fast_charge::1::0 usb/boost_current::1::0 charger/boost_current::1::0"`


### Google Pixel Cihazları

Üçüncü parti kablosuz cihazlarda hızlı şarjı zorlayın: `apply_on_plug=wireless/voltage_max::9000000`.

Bu bütün cihazlarda çalışmayabilir.
Çalışmadığında herhangi bir negatif etkisi yoktur.


### idle Mod and Alternatifler

1 - Idle mod destekleyen bir şarj portu seçmek (açık ara kazanan).
Cihazın kendi kendisine deşarj olabileceğini unutmayın.
Bu batarya sanki fiziksel olarak takılı değilmiş gibi çalışır.
Aşırı yavaş deşarj oranları beklendik sonuçlardır.

2 - `charging_switch=0`: eğer akım dalgalanıyor ise deneyiniz, aynı zamanda `current_workaround=true` (yalnızca yeniden başlatıldıktan sonra etkili olur).
Eğer bu method çalışıyorsa, etkisi aynı `#1` gibidir.

3 - `charging_switch=3900`: yalnızca voltaj kontrolü destekleyen cihazlarda çalışır.
Alışıldık idle mod'un aksine, cihaz sürekli olarak 3900mV'ta kalır.
Yüksek voltajlar için bu yöntem iyi değildir.
Bizler bataryaya binen stresi azaltmaya çalışıyoruz.
Uzun bir süre boyunca 3900 üstü bir voltaj tavsiye _edilmemektedir_.

4 - `acc 3900`: kısaca _acc 3900 3870_ (50 mV fark).
Voltaj kontrol desteği olmadan 3900mV aralığında kalmaya çalışır.
Evet, şaka falan değil.
Bu sıradan şarj portları ile çalışır.

5 - `acc 45 44`: bu az çok 3900 mV'a denk gelmektedir, çoğu durumda.
Voltaj ve batarya seviyesi (%) doğrusal bir ilişkiye sahip değillerdir.
Voltaj sıcaklığa göre, batarya ise kimyasına ve yaşına göre değişir.


---
## Sıkça sorulan sorular (SSS)


> Sorunları nasıl bildirebilirim?

GitHub üzerinden bildirin, veya geliştiriciye Facebook, Telegram (tercihen), XDA forum (link aşağıda).
Olabildiğince fazla bilgi vermeye çalışın.
Sorunu yaşadıktan _hemen sonra_ `acc -le` komutunun `/sdcard/Download/acc-logs-*.tgz` dizinindeki çıktısını da mesajınıza ilave edin.
Ayrıntılı bilgi için `Sorun Giderme > Tanı/Loglar` kısmına bakın.


> Neden benim cihazım için destek sağlamıyorsun? Yıllardır bekliyorum!

Öncelikle, biraz sabırlı olun!
Bazı sistemlerin kolay ulaşılabilir şarj kontrol dosyaları olmuyor; Bunlar için daha derinlere girmem -hatta bazen, üstüne bir şeyler koymam gerekiyor; bu da zaman ve emek gerektiriyor.
Son olarak, bazı sistemler şarj manipüle işlemini direkt desteklemiyor;  bu gibi durumlarda, farklı kernel'lar denemeniz ve güç kaynağınız için logları paylaşmanız gerekli.
bkz. `Güç kaynağı logları (yardım lazım)`.


> Why, when and how should I calibrate the battery manager?

With modern battery management systems, that's generally unnecessary.

However, if your battery is underperforming, you may want to try the procedure described at https://batteryuniversity.com/article/bu-603-how-to-calibrate-a-smart-battery .

ACC automatically optimizes system performance and battery utilization, by forcing `bg-dexopt-job` on daemon [re]start, once after boot, if charging and uptime >= 900 seconds.


> Voltajı 4080 mV olarak ayarladım ve bu 75% şarja denk geliyor.
Sürekli şarj mı etmeliyim, veya sürekli belirli aralıklar arasında şarjı durdurup başlatmalı mıyım?

Hangi methodun daha güvenli olduğu pek de önemli değil.
Önemli olan stabilite: voltaj ve şarj akımını ayarlamak.

4200mV veya yukarısında bir değer ile telefonunuzu uzun süre şarj altında bırakmadığınız sürece, bu kendi başına bile yeterince güvenli olacaktır.
Yoksa, öteki opsiyon daha yararlı olabilir- çünkü, yüksek voltaj altında geçirilen süreyi azaltmış olacaksınız.
Eğer aynı anda ikisini de kullanırsanız - her iki tarafın da artılarından yararlanabilirsiniz.
Bunun üstüne, cooldown cycle özelliğini aktif ederseniz, daha da yararlı olacaktır.

Daha önce neden lityum iyon bataryalar tamamen şarj olmuş şekilde satılmaz, düşündünüz mü? Genelde ~40-60% şarjlı olurlar. Neden?
Bataryayı uzun süreri dolu bırakmak, neredeyse tam dolu veya 70%+ şarjlı olması, kalıcı kapasite kaybına yol açar.

Bunların hepsinin uygulamaya dökersek...

Gece/yoğun işlem profili: max kapasite: 40-60% ve/veya voltaj 3900 mV civarları

Genel/günlük profil: max kapasite: 75-80% ve/veya voltaj 4100 mV'dan fazla olmayacak şekilde

Seyehat profili: kapasite 95% civarları ve/veya 4200 mV'dan fazla olmayacak şekilde

\* https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries/


> "-f|--force|--full [capacity]" komutu ne işe yarıyor anlamıyorum.

Şöyle bir senaryo düşünün:

Önemli bir etkinliğe gideceksiniz, zaman az.
Power bank'inizi çaldım ve Ebay'de satıyorum.
Telefonunuza ve dolu bir bataryaya ihtiyacınız var.
Etkinlikte bir güç kaynağına erişiminiz olmayacak, cihazı bütün gün Allah'ın varlığını unuttuğu bir yerde kullanacaksınız.
Bataryanızı kısa sürede olabildikçe fazla şarj etmeniz lazım.
Ancak, ACC Config dosyaları veya daemon yeniden başlatmak ile uğraşmak istemiyorsunuz.


> What's DJS?

It's a standalone program: Daily Job Scheduler.
As the name suggests, it's meant for scheduling "jobs" - in this context, acc profiles/settings.
Underneath, it runs commands/scripts at specified times - either once, daily and/or on boot.


> Do I have to install/upgrade both ACC and AccA?

To really get out of this dilemma, you have to understand what ACC and AccA essentially are.

ACC is a Android program that controls charging.
It can be installed as an app (e.g., AccA) module, Magisk module or standalone software. Its installer determines the installation path/variant. The user is given the power to override that.

A plain text file holds the program's configuration. It can be edited with any root text editor.
ACC has a command line interface (CLI) - which in essence is a set of Application Programing Interfaces (APIs). The main purpose of a CLI/API is making difficult tasks ordinary.

AccA is a graphical user interface (GUI) for the ACC command line. The main purpose of a GUI is making ordinary tasks simpler.
AccA ships with a version of ACC that is automatically installed when the app is first launched.

That said, it should be pretty obvious that ACC is like a fully autonomous car that also happens to have a steering wheel and other controls for a regular driver to hit a tree.
Think of AccA as a robotic driver that often prefers hitting people over trees.
Due to extenuating circumstances, that robot may not be upgraded as frequently as the car.
Upgrading the car regularly makes the driver happier - even though I doubt it has any emotion to speak of.
The back-end can be upgraded by flashing the latest ACC zip.
However, unless you have a good reason to do so, don't fix what's not broken.


> acc Andorid kapalı iken çalışıyor mu?

Hayır, ancak bu ihtimal hakkında araştırmalar yapıyorum.
Ama şu anda, recovery mod sırasında çalışıyor.


> Şarj devre dışı bırakılınca cihaz uyanıyor. Bununla nasıl başa çıkarım?

En iyi çözüm bu duruma sebep olmayan bir şarj portu kullanmak.
`Sorun Giderme > Şarj Portları` kısmına bakınız.
Bir öteki yaygın yöntem ise `resume_capacity = pause_capacity - 1`. örn., resume_capacity=74, pause_capacity=75.


---
## Linkler

- [Daily Job Scheduler](https://github.com/VR-25/djs)

- [Donate - Airtm, username: ivandro863auzqg](https://app.airtm.com/send-or-request/send)
- [Donate - Credit/Debit Card](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=iprj25@gmail.com&lc=US&item_name=VR25+is+creating+free+and+open+source+software.+Donate+to+suppport+their+work.&no_note=0&cn=&currency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted)
- [Donate - Liberapay](https://liberapay.com/vr25)
- [Donate - Patreon](https://patreon.com/vr25)
- [Donate - PayPal Me](https://paypal.me/vr25xda)

- [Facebook Page](https://fb.me/vr25xda)

- [Frontend - ACC App](https://github.com/MatteCarra/AccA/releases)
- [Frontend - ACC Settings](https://github.com/CrazyBoyFeng/AccSettings)

- [Must Read - How to Prolong Lithium Ion Batteries Lifespan](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries)

- [Telegram Channel](https://t.me/vr25_xda)
- [Telegram Group](https://t.me/acc_group)
- [Telegram Profile](https://t.me/vr25xda)

- [Upstream Repository](https://github.com/VR-25/acc)

- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)
