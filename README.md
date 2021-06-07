Genius open Customer oluştur

Eğer sistemde ilgili kart numarası varsa sadece karta ilgili tipte puan yükler,
Açık kart yoksa kartı açar ilgili tipte puanı yükler 

Prosedürü aşağıdaki gibi çalıştırabilirsiniz. 

EXEC	[SP_Customer_ekle]
		@CARDGIR = N'125655677', /*KART NUMARASI*/
		@TUTAR = 125, /*YUKLENECEK TUTAR*/
		@CUSTOMERNAME = N'YAVUZ', /*MUSTERİ ADI*/
		@KULLANICIKOD = 100, /*YUKLEYEN KODU*/
		@PUAN = 1  /*PUAN TIPI bonus_type tablosundaki tip*/ 


GO
