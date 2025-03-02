Süt Tankı Projesi – Mobil Uygulama Geliştirme ve API Entegrasyonu (Staj Projesi)

Bu proje, süt tanklarının uzaktan izlenmesi ve kontrol edilmesi amacıyla geliştirilmiş bir sistemin parçasıdır. Staj sürecim boyunca bu projede yer aldım ve süt tanklarının kontrolünü sağlayan mobil uygulamanın geliştirilmesine katkı sağladım. Projenin genel amacı, kullanıcıların tankların sıcaklık, ağırlık gibi parametrelerini mobil cihazları üzerinden takip edebilmesi ve gerektiğinde müdahalede bulunabilmesidir.

Uygulama Özellikleri:
Mobil Uygulama: Flutter kullanarak geliştirdiğimiz mobil uygulama, kullanıcıların tankların verilerini görüntülemelerini ve farklı parametreleri (sıcaklık, ağırlık, vs.) ayarlamalarını sağlıyor.
API Entegrasyonu: ASP.NET Core kullanarak geliştirdiğimiz API'ler aracılığıyla uygulama, SQL Server veritabanı ile entegre bir şekilde çalışıyor. Veritabanındaki verilere erişim sağlanarak sıcaklık ve ağırlık verileri güncelleniyor.
Veri Güncelleme ve Kontrol: Kullanıcılar, mobil uygulama üzerinden sıcaklık değerlerini artırıp azaltabiliyor.Ağırlığı değişimini garfik üzerinden izleyebiliyor. Bu değişiklikler SQL veritabanında kaydediliyor ve gerekli işlemler veritabanı tarafında yapılacak şekilde yapılandırılmıştır.
Gerçek Zamanlı Veritabanı İletişimi: API'ler üzerinden veri çekme ve veritabanına veri gönderme işlemleri Postman ile test edilip uygulama üzerinde başarılı bir şekilde çalışacak şekilde entegre edilmiştir.
Kullanılan Teknolojiler:
Mobil Uygulama: Flutter
Backend/API: ASP.NET Core
Veritabanı: SQL Server
Veri Yönetimi: API ile SQL Server üzerinden sıcaklık ve ağırlık verilerinin düzenlenmesi ve kaydedilmesi sağlanmıştır.
Ekip Çalışması:
Bu proje tamamen bir ekip çalışmasıydı ve ben de stajyer olarak bu ekibin bir parçasıydım. Ekip arkadaşlarımla birlikte, proje gereksinimlerini belirledik, işbölümü yaparak görevleri üstlendik ve geliştirme sürecini birlikte yürüttük. Benim sorumluluğum, mobil uygulamanın geliştirilmesi, API'ler ile entegrasyon ve veritabanı ile bağlantılı işlemlerin yapılmasıydı. Proje boyunca, hem teknik bilgi hem de ekip içi işbirliği konusunda değerli deneyimler kazandım.

Çalışma Prensibi:
Mobil uygulama, kullanıcıların tankların verilerini görselleştirmelerine olanak tanırken aynı zamanda, kullanıcı etkileşimlerine göre cihazın çalışma parametrelerini değiştirip bu değişiklikleri SQL tabanına kaydeder. Bu sayede, kullanıcılar her zaman güncel verilere ulaşabilir ve gerektiğinde tankların çalışma koşullarını manuel olarak ayarlayabilirler.
