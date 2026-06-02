# Computer Vision Based Object Tracking & Telemetry Dashboard

Bu proje, MATLAB ortamında harici bir kütüphaneye ihtiyaç duymadan, bilgisayar kamerasından (Webcam) alınan canlı video akışı üzerinden **gerçek zamanlı nesne takibi, yörünge kestirimi ve dinamik telemetri analizi** yapan bir görüntü işleme yazılımıdır. 

Sistem; askeri takip radarlarının ve telemetri istasyonlarının çalışma prensiplerini simüle etmek üzere tasarlanmıştır.

## Öne Çıkan Özellikler

* **Işık Bağımsız HSV Filtreleme:** Ortamdaki ışık ve gölge değişimlerinden minimum düzeyde etkilenmesi için RGB kareler dinamik olarak HSV (Hue, Saturation, Value) renk uzayına dönüştürülerek kararlı bir kırmızı/mavi ton algılaması sağlanır.
* **Yüz/Deri Tonu Baskılama (False-Positive Protection):** İnsan ten renginin kırmızı spektrumuna giren soluk tonları, geliştirilen akıllı doygunluk (Saturation) ve parlaklık (Value) eşikleri sayesinde filtrelenir. Böylece kullanıcının yüzü veya burnu hedef olarak algılanmaz.
* **Anlık Hız Analizi (Matematiksel Diferansiyel Kestirim):** Hedefin ardışık iki kare arasındaki yer değişimi, Öklid Mesafesi bağıntısı ($d = \sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}$) kullanılarak anlık hız vektörüne (piksel/kare) dönüştürülür.
* **Yörünge Kuyruk Efekti (Trajectory Tracking):** Nesnenin uzayda geçtiği son 15 karelik konum geçmişi bellekte tutularak canlı kamera ekranı üzerine dinamik bir "kuyruk izi" olarak yansıtılır.
* **Gerçek Zamanlı Telemetri Dashboard'u:** Nesne hareket ederken eş zamanlı olarak X/Y konum grafikleri ve dinamik hız değişim alanı (`area plot`) güncellenir.
* **Asenkron Bellek Yönetimi (UI Safe Close):** Sol altta bulunan kırmızı buton yardımıyla döngü kırılarak donanım (kamera) ve işletim sistemi arasındaki bağ, bellek sızıntısı (memory leak) oluşmadan güvenle kapatılır.

## ⚙️ Gereksinimler & Toolbox Listesi

Projenin tıkır tıkır çalışması için MATLAB üzerinde şu paketlerin kurulu olması gerekir:
* **Computer Vision Toolbox**
* **MATLAB Support Package for USB Webcams** *(Eğer yüklü değilse MATLAB Add-On Explorer üzerinden tek tıkla ücretsiz kurabilirsiniz).*

## Kurulum ve Çalıştırma

1. Bu depoyu (repository) bilgisayarınıza indirin veya Git ile klonlayın:
   ```bash
   git clone [https://github.com/nisanurkrmzsln/Nesne_Takibi.git](https://github.com/nisanurkrmzsln/Nesne_Takibi.git)
   
