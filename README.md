# Vertigo Games - Technical Artist Case Study

## Sahnelerin Konumu
*   **UI Sahnesi (Task 1):** `Assets/VertigoCase/Scene_UI.unity`
*   **Silah Sahnesi (Task 2):** `Assets/VertigoCase/Scene_Weapon.unity`

## Kurulum ve Unity Sürümü
*   **Unity Sürümü:** Proje **Unity 6 (6000.3.10f1)** sürümüyle geliştirilmiştir. Uyumluluk sorunları yaşamamak adına bu sürümle açılması tavsiye edilir.

---

## Test Edilecek Etkileşimler

### 1. Battle Pass UI (`Scene_UI`)
UI sahnesini açıp Unity Editor üzerinde **Play** butonuna basarak aşağıdaki özellikleri test edebilirsiniz:
*   **Kaydırma (Scroll):** Mouse sol tuşu ile sürükleyerek Battle Pass kartları arasında sağa/sola kaydırma (scroll) yapabilirsiniz.
*   **Seviye ve Deneyim Testi (Level & XP):** Hierarchy'de yer alan `BattlePassManager` bileşeni üzerinden **`Current Level`** ve **`Current XP`** değerlerini elle değiştirerek seviye ilerlemesini ve kartların dinamik güncellenmesini anlık olarak test edebilirsiniz.
*   **Premium Ödüller:** Yine `BattlePassManager` üzerindeki **`isPremium`** seçeneğini aktif/deaktif ederek premium ödül akışını ve kilit açılma durumlarını inceleyebilirsiniz.
*   **Ödül Kartı Etkileşimi:** Fareyle claimable (alınabilir) durumdaki kartlara tıklayarak ödül alma VFX'lerini test edebilirsiniz.
*   **Performans:** UI sistemi, performansı korumak adına tamamen **event tabanlı** bir mimariyle geliştirilmiştir (kod tasarımı aşamasında yapay zeka desteğinden yararlanılmıştır). Ayrıca build time için sprite atlas hazırlanıp build alarak draw call sayısının editöre göre daha düşük olduğu teyit edilmiştir.

### 2. Silah Showroom (`Scene_Weapon`)
Silah sahnesini açıp Unity Editor üzerinde **Play** butonuna basarak aşağıdaki etkileşimleri deneyimleyebilirsiniz:
*   **Fareyle Döndürme (Drag to Rotate):** Silahı ekran üzerinde sol tıkla tutup sürükleyerek kendi ekseninde döndürebilirsiniz. Sürüklemeyi bıraktığınızda silah kısa bir süre sonra otomatik dönmeye devam eder.
*   **Smooth Zoom:** Fare tekerleğini (Mouse Wheel) kullanarak silaha yakınlaşıp uzaklaşabilirsiniz.

Saygılarımla,  
**Enes Halıcı**
