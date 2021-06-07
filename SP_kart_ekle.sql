USE Genius3;
GO

ALTER PROCEDURE SP_Customer_ekle
(
    @CARDGIR NVARCHAR(20),       /*YENİ KART NO*/
    @TUTAR MONEY,                /*KARTA YUKLENECEK TUTAR*/
    @CUSTOMERNAME NVARCHAR(100), /*MUSTERI ADI*/
    @KULLANICIKOD INT,           /*KAYDI YAPAN KISININ GENİUS KODU*/
    @PUAN INT                    /*BONUS TYPE TABLOSUNDAKİ YUKLENMEK İSTENEN PUAN TIPININ KOD DEĞERİ */
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MESAJ NVARCHAR(MAX);
    DECLARE @PUANTYPE INT;
    DECLARE @CTBID BIGINT;
    DECLARE @AMOUNT INT;
    SET @CTBID =
    (
        SELECT ID FROM GENIUS3.SEQUENCE WHERE DESCRIPTION = 'CUSTOMER_TOTAL_BONUS'
    ); /*CUSTOMER_TOTAL_BONUS ID*/

    SET @PUANTYPE =
    (
        SELECT [GENIUS3].[FNC_PUAN_TIPI](DESCRIPTION)
        FROM GENIUS3.BONUS_TYPE
        WHERE CODE = @PUAN
    ); /*YUKLENECEK PUAN TIPI*/
    SET @KULLANICIKOD =
    (
        SELECT ID FROM USERS WHERE CODE = @KULLANICIKOD
    ); /*KULLANICI KODU ID*/
    DECLARE @ID BIGINT;
    SET @ID =
    (
        SELECT ID FROM GENIUS3.SEQUENCE WHERE DESCRIPTION = 'CUSTOMER'
    ); /*CUSTOMER ID*/
    DECLARE @CRDID BIGINT;
    SET @CRDID =
    (
        SELECT ID FROM GENIUS3.SEQUENCE WHERE DESCRIPTION = 'CARD'
    ); /*CARD ID*/

    SET @AMOUNT = @TUTAR * 100; /*YUKLENECEK PUANI DUZENLE*/
    IF EXISTS (SELECT * FROM GENIUS3.CUSTOMER WHERE CODE = @CARDGIR)

        /*KART VAR SADECE PUAN YUKLEMESİ YAPILACAK*/
        UPDATE GENIUS3.CUSTOMER_TOTAL_BONUS
        SET FK_BONUS_TYPE = @PUANTYPE,
            BONUS = @AMOUNT,
            MODIFY_DATE = GETDATE(),
            CREATE_DATE = GETDATE(),
            LAST_EARN_TIME = GETDATE()
        WHERE FK_CUSTOMER IN
              (
                  SELECT ID FROM GENIUS3.CUSTOMER WHERE CODE = @CARDGIR
              );
    IF EXISTS (SELECT * FROM CARD WHERE CODE = @CARDGIR)/*KART VAR SADECE PUAN YUKLENECEK*/
    BEGIN
        UPDATE GENIUS3.CARD
        SET BONUS = @TUTAR
        WHERE FK_CUSTOMER IN
              (
                  SELECT ID FROM GENIUS3.CUSTOMER WHERE CODE = @CARDGIR
              );
        PRINT 'KART SİSTEMDE VAR SADECE PUAN YUKLENDI';
    END;

    ELSE
    BEGIN

        IF NOT EXISTS (SELECT * FROM CARD WHERE CODE = @CARDGIR)
        BEGIN


            INSERT INTO GENIUS3.CUSTOMER
            (
                ID,
                CODE,
                NAME,
                DISCOUNT_LIMIT,
                DISCOUNT_PERCENT,
                DISCOUNT_FLAG,
                CK_STOCK_PRICE_NO,
                BONUS,
                TC_IDENTITY_NO,
                FK_STORE_TYPE,
                PARAM1,
                PARAM2,
                CREATE_DATE,
                FK_USER_CREATE,
                MODIFY_DATE,
                FK_USER_MODIFY,
                FK_STORE_LU,
                FK_STORE_LS,
                UPDATESEQ,
                AKTARILDI
            )
            VALUES
            (   @ID,           -- ID - udt_ID
                @CARDGIR,      -- CODE - nvarchar(24)
                @CUSTOMERNAME, -- NAME - nvarchar(100)
                0.0,           -- DISCOUNT_LIMIT - float
                0.0,           -- DISCOUNT_PERCENT - float
                0,             -- DISCOUNT_FLAG - smallint
                0,             -- CK_STOCK_PRICE_NO - smallint
                @TUTAR,        -- BONUS - money
                N'',           -- TC_IDENTITY_NO - nvarchar(15)
                '1161',        -- FK_STORE_TYPE - udt_ID
                N'',           -- PARAM1 - nvarchar(20)
                N'',           -- PARAM2 - nvarchar(20)
                GETDATE(),     -- CREATE_DATE - smalldatetime
                @KULLANICIKOD, -- FK_USER_CREATE - udt_ID
                GETDATE(),     -- MODIFY_DATE - smalldatetime
                0,             -- FK_USER_MODIFY - udt_ID
                0,             -- FK_STORE_LU - udt_ID
                0,             -- FK_STORE_LS - udt_ID
                0,             -- UPDATESEQ - int
                0              -- AKTARILDI - smallint
                ); /*CUSTOMER EKLE*/
            INSERT INTO GENIUS3.CARD
            (
                ID,
                CODE,
                PASSWORD,
                FK_CUSTOMER,
                EXPIRE_DATE,
                GIVEN_DATE,
                STATUS,
                BONUS,
                CAMPAIGN_PROCESS_TYPE,
                CREATE_DATE,
                FK_USER_CREATE,
                MODIFY_DATE,
                FK_USER_MODIFY,
                FK_STORE_LU,
                FK_STORE_LS,
                UPDATESEQ,
                IS_REDEEMER
            )
            VALUES
            (   @CRDID,        -- ID - udt_ID
                @CARDGIR,      -- CODE - nvarchar(24)
                N'',           -- PASSWORD - nvarchar(4)
                @ID,           -- FK_CUSTOMER - udt_ID
                GETDATE(),     -- EXPIRE_DATE - datetime
                GETDATE(),     -- GIVEN_DATE - smalldatetime
                2,             -- STATUS - tinyint
                @TUTAR,        -- BONUS - money
                1,             -- CAMPAIGN_PROCESS_TYPE - tinyint
                GETDATE(),     -- CREATE_DATE - smalldatetime
                @KULLANICIKOD, -- FK_USER_CREATE - udt_ID
                GETDATE(),     -- MODIFY_DATE - smalldatetime
                @KULLANICIKOD, -- FK_USER_MODIFY - udt_ID
                '1161',        -- FK_STORE_LU - udt_ID
                '1161',        -- FK_STORE_LS - udt_ID
                0,             -- UPDATESEQ - int
                1              -- IS_REDEEMER - bit
                ); /*KART EKLE*/
            /*CUSTOMER_TOTAL_BONUS*/


            INSERT INTO [GENIUS3].[CUSTOMER_TOTAL_BONUS]
            (
                [ID],
                [FK_CUSTOMER],
                [FK_BONUS_TYPE],
                [BONUS],
                [CREATE_DATE],
                [MODIFY_DATE],
                [LAST_EARN_TIME]
            )
            VALUES
            (@CTBID, @ID, @PUANTYPE, @AMOUNT, GETDATE(), GETDATE(), GETDATE());
            SET @ID = @ID + 1;
        END;
        UPDATE GENIUS3.SEQUENCE
        SET ID = @ID
        WHERE DESCRIPTION = 'CUSTOMER'; /*CUSTOMER SEQUENCE YÜKSELT*/
        SET @CRDID = @CRDID + 1;
        UPDATE GENIUS3.SEQUENCE
        SET ID = @CRDID
        WHERE DESCRIPTION = 'CARD'; /*CARD SEQUENCE YÜKSELT*/
        SET @CTBID = @CTBID + 1;
        UPDATE GENIUS3.SEQUENCE
        SET ID = @CRDID
        WHERE DESCRIPTION = 'CUSTOMER_TOTAL_BONUS'; /*CUSTOMER_TOTAL_BONUS SEQUENCE YÜKSELT*/
        PRINT 'KART SİSTEMDE YOK, YENİ KART TANIMLAMASI YAPILDI VE PUAN YUKLENDİ  ';
    END;
END;