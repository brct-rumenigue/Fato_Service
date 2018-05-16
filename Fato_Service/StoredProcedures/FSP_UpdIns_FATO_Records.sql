USE BookingDB_ERP_BC
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[FSP_UpdIns_FATO_Records]
    @FromDate DATETIME = NULL ,
    @ToDate DATETIME = NULL ,
    @Company_Id VARCHAR(10) ,
    @Product VARCHAR(3) = NULL ,
    @QueryNo INT = 1 ,
    @Booking_ref VARCHAR(10) = NULL
AS
    BEGIN
        SET FMTONLY OFF
        SET NOCOUNT ON

        CREATE TABLE #all_product
            (
              Booking_Ref VARCHAR(20) ,
              Company_id VARCHAR(10) ,
              Affiliate_Id VARCHAR(20) ,
              CPF_No VARCHAR(40) ,
              Sales_Channel VARCHAR(10) ,
              Booking_Date DATETIME ,
              Allocation_Date VARCHAR(20) ,
              Trip_Start_Date VARCHAR(20) ,
              Trip_End_Date VARCHAR(20) ,
              Lead_Pax VARCHAR(500) ,
              Product VARCHAR(50) ,
              Supplier_Code1 VARCHAR(50) ,
              Supplier_Code2 VARCHAR(50) ,
              Supplier_Code3 VARCHAR(50) ,
              Supplier_Code4 VARCHAR(50) ,
              City CHAR(10) ,
              State CHAR(20) ,
              Status VARCHAR(30) ,
              No_of_Passenger VARCHAR(5) ,
              CPP VARCHAR(20) ,
              payment_type VARCHAR(30) ,
              PNR_No1 VARCHAR(100) ,
              PNR_No2 VARCHAR(100) ,
              PNR_No3 VARCHAR(100) ,
              PNR_No4 VARCHAR(100) ,
              Itinerary_Detail VARCHAR(500) ,
              MarketType VARCHAR(10) ,
              Hotel_Exchange_Rate DECIMAL(18, 3) ,
              NetRate1 DECIMAL(18, 3) ,
              NetRate2 DECIMAL(18, 3) ,
              NetRate3 DECIMAL(18, 3) ,
              NetRate4 DECIMAL(18, 3) ,
              Tax DECIMAL(18, 3) ,
              RAV DECIMAL(18, 3) ,
              Supplier_Fee1 DECIMAL(18, 3) ,
              Supplier_Fee2 DECIMAL(18, 3) ,
              Supplier_Fee3 DECIMAL(18, 3) ,
              Supplier_Fee4 DECIMAL(18, 3) ,
              Trans_Fee1 DECIMAL(18, 3) ,
              Trans_Fee2 DECIMAL(18, 3) ,
              Trans_Fee3 DECIMAL(18, 3) ,
              Trans_Fee4 DECIMAL(18, 3) ,
              Total_Value_Supplier DECIMAL(18, 3) ,
              Total_Value_Charged DECIMAL(18, 3) ,
              Bonus_Points DECIMAL(18, 3) ,
              Cash DECIMAL(18, 3) ,
              CC_Amount1 DECIMAL(18, 3) ,
              Installment_Amount1 DECIMAL(18, 3) ,
              Trans_ID1 VARCHAR(50) ,
              CC_Amount2 DECIMAL(18, 3) ,
              Installment_Amount2 DECIMAL(18, 3) ,
              Trans_ID2 VARCHAR(50) ,
              CC_Amount3 DECIMAL(18, 3) ,
              Installment_Amount3 DECIMAL(18, 3) ,
              Trans_ID3 VARCHAR(50) ,
              CC_Amount4 DECIMAL(18, 3) ,
              Installment_Amount4 DECIMAL(18, 3) ,
              Trans_ID4 VARCHAR(50) ,
              Itn_Status1 VARCHAR(50) ,
              Itn_Status2 VARCHAR(50) ,
              Itn_Status3 VARCHAR(50) ,
              Itn_Status4 VARCHAR(50) ,
              CC_Company1 VARCHAR(50) ,
              CC_Company2 VARCHAR(50) ,
              CC_Company3 VARCHAR(50) ,
              CC_Company4 VARCHAR(50) ,
              Change_Status BIT ,

      --------------------------Recurrence------------------------------------------  
              CC_AmountRecurrence1 DECIMAL(18, 3) ,
              Installment_AmountRecurrence1 DECIMAL(18, 3) ,
              Trans_IDRecurrence1 VARCHAR(50) ,
              CC_AmountRecurrence2 DECIMAL(18, 3) ,
              Installment_AmountRecurrence2 DECIMAL(18, 3) ,
              Trans_IDRecurrence2 VARCHAR(50) ,
              CC_AmountRecurrence3 DECIMAL(18, 3) ,
              Installment_AmountRecurrence3 DECIMAL(18, 3) ,
              Trans_IDRecurrence3 VARCHAR(50) ,
              CC_AmountRecurrence4 DECIMAL(18, 3) ,
              Installment_AmountRecurrence4 DECIMAL(18, 3) ,
              Trans_IDRecurrence4 VARCHAR(50) ,

   --------------------------Recurrence END------------------------------------------
   --------------------------Discount Coupon------------------------------------------
              Discount_Amount1 DECIMAL(18, 3) ,
              Discount_Type1 VARCHAR(50) ,
              Discount_Amount2 DECIMAL(18, 3) ,
              Discount_Type2 VARCHAR(50) ,
              Discount_Amount3 DECIMAL(18, 3) ,
              Discount_Type3 VARCHAR(50) ,   
   --------------------------Discount Coupon END------------------------------------------
              branch_id SMALLINT
            )

        CREATE TABLE #all_booking_ref
            (
              RecordId INT IDENTITY(1, 1) ,
              Booking_Ref VARCHAR(20) ,
              Company_id VARCHAR(10) ,
              affiliate_id VARCHAR(20) ,
              Sales_Channel VARCHAR(10) ,
              date_of_booking DATETIME ,
              ClientCompanyCNPJ VARCHAR(50) ,
              destination CHAR(10) ,
              Final_Status VARCHAR(50) ,
              client_id VARCHAR(10) ,
              branch_id SMALLINT
            )

        DECLARE @query VARCHAR(2000)

        SET @query = '	insert into #all_booking_ref(Booking_Ref,Company_id,affiliate_id,Sales_Channel,date_of_booking,ClientCompanyCNPJ,destination,Final_Status,client_id, branch_id)
						select booking_ref,company_id,affiliate_id,Sales_Channel,date_of_booking,ClientCompanyCNPJ,destination,Final_Status,client_id, branch_id
						from booking_master (nolock)
						where company_id=''' + @Company_Id + ''''

        IF ISNULL(@Booking_ref, '') != ''
            BEGIN
                SET @query = @query + ' and booking_ref=' + @Booking_ref
            END
        ELSE
            BEGIN
                SET @query = @query + ' and date_of_booking >= '''
                    + CONVERT(VARCHAR, @FromDate)
                    + '''  AND date_of_booking < '''
                    + CONVERT(VARCHAR, @ToDate)
                    + ''' order by booking_ref desc '
            END

        EXEC(@query)

		--Update Temp table "all_product" from Booking_Master Table  
        INSERT  INTO #all_product
                ( Booking_Ref ,
                  Company_id ,
                  Booking_Date ,
                  branch_id
                )
        SELECT  Booking_Ref ,
                Company_id ,
                date_of_booking ,
                branch_id
        FROM    #all_booking_ref

        CREATE TABLE #Credit_Info
            (
              Id INT IDENTITY(1, 1) ,
              Booking_Ref VARCHAR(20) ,
              CC_Amount DECIMAL(18, 3) ,
              CC_Company VARCHAR(50) ,
              Installment_Amount DECIMAL(18, 3) ,
              Trans_ID VARCHAR(50) ,
              NO_Of_Installment DECIMAL(18, 3) ,
              Occurence INT
            )--,payment_mode varchar(100))

        INSERT  INTO #Credit_Info
                ( Booking_Ref ,
                  CC_Amount ,
                  CC_Company ,
                  Installment_Amount ,
                  Trans_ID ,
                  NO_Of_Installment ,
                  Occurence
                )--,payment_mode)
                SELECT  pa.booking_ref ,
                        pa.allocated_amount ,
                        ccd.cc_company ,
                        pa.allocated_amount
                        / CASE WHEN pa.No_Of_Installments = 0 THEN 1
                               ELSE ISNULL(pa.No_Of_Installments, 1)
                          END ,
                        pa.eft_seq_no ,
                        ISNULL(pa.No_Of_Installments, 0) ,
                        '0'--,ISNULL(pa.payment_mode,'')
                FROM    payment_allocation pa ( NOLOCK )
                        JOIN credit_card_details ccd ( NOLOCK ) ON pa.pay_allocation_id = ccd.pay_allocation_id
                WHERE   pa.payment_mode = 'CREDIT'
                        AND Booking_Ref IN ( SELECT Booking_Ref
                                             FROM   #all_product )

  ---------For recurrence change----------
        CREATE TABLE #Recurr_Info
            (
              Id INT IDENTITY(1, 1) ,
              Booking_Ref VARCHAR(20) ,
              CC_Amount DECIMAL(18, 3) ,
              CC_Company VARCHAR(50) ,
              Installment_Amount DECIMAL(18, 3) ,
              Trans_ID VARCHAR(50) ,
              NO_Of_Installment DECIMAL(18, 3) ,
              Occurence INT
            )--,payment_mode varchar(100))

        INSERT  INTO #Recurr_Info
                ( Booking_Ref ,
                  CC_Amount ,
                  CC_Company ,
                  Installment_Amount ,
                  Trans_ID ,
                  NO_Of_Installment ,
                  Occurence
                )--,payment_mode)
                SELECT  pa.booking_ref ,
                        pa.allocated_amount ,
                        ccd.cc_company ,
                        pa.allocated_amount
                        / CASE WHEN pa.No_Of_Installments = 0 THEN 1
                               ELSE ISNULL(pa.No_Of_Installments, 1)
                          END ,
                        pa.eft_seq_no ,
                        ISNULL(pa.No_Of_Installments, 0) ,
                        '0'--,ISNULL(pa.payment_mode,'')
                FROM    payment_allocation pa ( NOLOCK )
                        JOIN credit_card_details ccd ( NOLOCK ) ON pa.pay_allocation_id = ccd.pay_allocation_id
                WHERE   pa.payment_mode = 'RECURRENCY'
                        AND Booking_Ref IN ( SELECT Booking_Ref
                                             FROM   #all_product )

  ------------End recurrence change---------
        CREATE TABLE #tmptbl
            (
              Id INT IDENTITY(1, 1) ,
              Occurence INT ,
              Booking_Ref VARCHAR(20) ,
              Company_Id VARCHAR(10) ,
              affiliate_code VARCHAR(50) ,
              Affiliate_Id VARCHAR(50) ,
              Supplier_Code VARCHAR(50) ,
              MarketType VARCHAR(10) ,
              Lead_Pax VARCHAR(202) ,
              Sales_Channel VARCHAR(10) ,
              Booking_Date VARCHAR(20) ,
              Allocation_Date VARCHAR(20) ,
              Trip_Start_Date VARCHAR(20) ,
              Trip_End_Date VARCHAR(20) ,
              CPF_No VARCHAR(40) ,
              Product_Type VARCHAR(10) ,
              PNR_No VARCHAR(50) ,
              City CHAR(3) ,
              State CHAR(20) ,
              Status VARCHAR(20) ,
              No_of_Passenger VARCHAR(5) ,
              CPP VARCHAR(20) ,
              payment_type VARCHAR(20) ,
              TransFee DECIMAL(18, 3) ,
              Net_Fare DECIMAL(18, 3) ,
              Gross_Tax DECIMAL(18, 3) ,
              Total_Gross_Fare DECIMAL(18, 3) ,
              Total_Net_Fare DECIMAL(18, 3) ,
              RAV DECIMAL(18, 3) ,
              SupplierFee DECIMAL(18, 3) ,
              BonusPoints VARCHAR(10) ,
              Total_Cash_Amount DECIMAL(18, 3) ,

   --CC_Amount decimal(18,3),

   --CC_FirstInstallment decimal(18,3),

   --No_Of_Installments int,

   --Auth_Code varchar(20),
              ROE DECIMAL(18, 3) ,
              Itinerary_Type VARCHAR(300) ,

   --CC_Company varchar(10),
              Itn_Status VARCHAR(20) ,
   --------------------------Discount Coupon------------------------------------------
              Discount_Amount1 DECIMAL(18, 3) ,
              Discount_Type1 VARCHAR(50) ,
              Discount_Amount2 DECIMAL(18, 3) ,
              Discount_Type2 VARCHAR(50) ,
              Discount_Amount3 DECIMAL(18, 3) ,
              Discount_Type3 VARCHAR(50) ,
   --------------------------Discount Coupon END------------------------------------------ 
              branch_id SMALLINT
            )
	
	--insert data into the temp table from all sp's

		--Flight Code Start
        INSERT  INTO #tmptbl
                SELECT  '0' Occurence ,
                        ABR.Booking_Ref AS Booking_Ref ,
                        ABR.Company_id AS Company_Id ,
                        ABR.affiliate_id ,
                        ISNULL(am.affiliate_code,
                               ( SELECT CASE WHEN ABR.branch_id = 1 THEN 'SBV'
                                             ELSE branch_name
                                        END
                                 FROM   dbo.company_branch _cb ( NOLOCK )
                                 WHERE  _cb.branch_id = ABR.branch_id
                               )) AS affiliate_code ,
                        ( SELECT    dbo.fn_GetSupplierNameNCode(1, 'F',
                                                              ABR.Booking_Ref,
                                                              @Company_Id,
                                                              fd.GDS_Id)
                        ) + '-'
                        + ( SELECT  dbo.fn_GetSupplierAirlienName('AIR',
                                                              fd.airline)
                          ) AS Supplier_Code ,
                        fd.market_type AS MarketType ,
                        LeadPaxName AS Lead_Pax ,
                        ISNULL(UPPER(ABR.Sales_Channel), '--') AS Sales_Channel ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, ABR.date_of_booking, 101), 103),
                               '--') Booking_Date ,
                        ISNULL(paCredit.Allocation_Date, '--') Allocation_Date ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, fd.start_date, 101), 103),
                               '--') Trip_Start_Date ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, fsd1.date_of_departure, 101), 103),
                               '--') Trip_End_Date ,
                        CASE WHEN ISNULL(ABR.ClientCompanyCNPJ, '') <> ''
                             THEN ABR.ClientCompanyCNPJ
                             ELSE ISNULL(cm.CPF_No, '')
                        END CPF_No ,
                        'AIR' AS Product_Type ,
                        ISNULL(fd.pnr_no, '') AS PNR_No ,
                        ABR.destination AS City ,
                        '' State ,
                        ISNULL(ABR.Final_Status, '') Status ,
                        ISNULL(fpp.No_of_Passenger, 0) No_of_Passenger ,
                        ( SELECT TOP ( 1 )
                                    Points_Conversion_Rate
                          FROM      Payment_Point_Allocation (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                        ) CPP ,
                        CASE WHEN bpp.total_amount_allocated > 0
                                  AND ( ( ISNULL(paCash.Cash_Amount, 0)
                                          + ISNULL(paCredit.Credit_Amount_inc_Tax,
                                                   0) ) > 0 )
                             THEN 'CASH+BONUS'
                             ELSE CASE WHEN bpp.total_amount_allocated > 0
                                       THEN 'BONUS'
                                       ELSE 'CASH'
                                  END
                        END payment_type ,
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Airline Transfee'
                                    AND fd.flight_id = product_booking_id
                        ) TransFee ,
                        CASE WHEN ISNULL(fd.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(canx.canx_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(ff.net_fare, 0)
                        END Net_Fare ,
                        CASE WHEN ISNULL(fd.status, 'OK') = 'CANCELLED' THEN 0
                             ELSE ISNULL(ff.gross_tax, 0)
                        END Gross_Tax ,
                        CASE WHEN ISNULL(fd.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(canx.canx_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(ff.net_fare, 0)
                                  + ISNULL(bc.gross_charge, 0)
                                  + ISNULL(ff.gross_tax, 0) + ISNULL(ff.RAV, 0)
                        END Total_Gross_Fare ,
                        CASE WHEN ISNULL(fd.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(canx.canx_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(ff.net_fare, 0)
                                  + ISNULL(bc.gross_charge, 0)
                                  + ISNULL(ff.gross_tax, 0) + ISNULL(ff.RAV, 0)
                                  - ( SELECT    ISNULL(SUM(gross_charge), 0)
                                      FROM      booking_charges (NOLOCK)
                                      WHERE     Booking_Ref = ABR.Booking_Ref
                                                AND charge_type = 'Airline Transfee'
                                    )
                        END Total_Net_Fare ,
                        ff.RAV ,
                        ( SELECT    ISNULL(SUM(gross_charge), 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Supplier Fee'
                        ) AS SupplierFee ,
                        ISNULL(total_points_allocated, 0.000) AS BonusPoints ,
                        ( ISNULL(paCash.Cash_Amount, 0)
                          + ISNULL(paCredit.Credit_Amount_inc_Tax, 0) ) Total_Cash_Amount ,
                        '0' AS ROE ,
                        ( SELECT    BookingDB_ERP_BC.dbo.fn_getJourneyType(ABR.Booking_Ref,
                                                              @Company_Id)
                        ) AS Itinerary_Type ,
                        CASE WHEN ISNULL(fsd.Status, '') = 'OK'
                                  OR ISNULL(fsd.Status, '') = 'HK'
                             THEN 'Confirmed'
                             WHEN ISNULL(fsd.Status, '') = 'RQ'
                                  OR ISNULL(fsd.Status, '') = 'UC'
                             THEN 'UnConfirmed'
                             WHEN ISNULL(fsd.Status, '') = 'HX'
                             THEN 'Cancelled'
                             ELSE ISNULL(fsd.Status, '')
                        END Itinerary_status ,
						--Discount
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Bonus'
                                    AND fd.flight_id = product_booking_id
                        ) AS Discount_Amount1 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Bonus'
                                    AND fd.flight_id = product_booking_id
                        ) AS Discount_Type1 ,
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount'
                                    AND fd.flight_id = product_booking_id
                        ) AS Discount_Amount2 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount'
                                    AND fd.flight_id = product_booking_id
                        ) AS Discount_Type2 ,
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Tax'
                                    AND fd.flight_id = product_booking_id
                        ) AS Discount_Amount3 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Tax'
                                    AND fd.flight_id = product_booking_id
                        ) AS Discount_Type3 ,
						-- Discount
                        ABR.branch_id
                FROM    #all_booking_ref ABR --INNER JOIN booking_master bm on bm.booking_ref=#all_booking_ref.Booking_Ref
                        INNER JOIN flight_details fd ( NOLOCK ) ON fd.Booking_Ref = ABR.Booking_Ref
                        INNER JOIN ( SELECT flight_id ,
                                            Booking_Ref ,
                                            SUM(ISNULL(ws_net_rate, 0)
                                                * no_of_passengers) net_fare ,
                                            SUM(ISNULL(ws_gross_rate, 0)
                                                * no_of_passengers) gross_fare ,
                                            SUM(( ISNULL(gross_tax, 0)
                                                  + ISNULL(tds, 0)
                                                  - ISNULL(RAV_Amount, 0) )
                                                * no_of_passengers) gross_tax ,
                                            SUM(( ISNULL(RAV_Amount, 0) )
                                                * no_of_passengers)
                                            + SUM(ISNULL(transaction_fee, 0)) RAV
                                     FROM   flight_fare (NOLOCK)
                                     GROUP BY flight_id ,
                                            Booking_Ref
                                   ) ff ON ff.flight_id = fd.flight_id
                        INNER JOIN AgentName_VW agv ( NOLOCK ) ON ABR.Booking_Ref = agv.Booking_Ref
                        INNER JOIN client_master cm ( NOLOCK ) ON cm.client_id = ABR.client_id
                        LEFT OUTER JOIN ( SELECT    flight_id ,
                                                    SUM(ISNULL(airline_charge,
                                                              0)
                                                        + ISNULL(company_charge,
                                                              0)) AS canx_charge
                                          FROM      flight_canx_charge (NOLOCK)
                                          GROUP BY  flight_id ,
                                                    Booking_Ref
                                        ) canx ON canx.flight_id = fd.flight_id
                        LEFT OUTER JOIN Supplier_Master sm ( NOLOCK ) ON sm.Supplier_Id = fd.airticket_supplier
                        LEFT OUTER JOIN Affiliate_Master am ( NOLOCK ) ON am.affiliate_id = ABR.affiliate_id
                        LEFT OUTER JOIN ( SELECT    ppa.booking_ref ,
                                                    Product_ID ,
                                                    Product_Type ,
                                                    Pay_Allocation_ID ,
                                                    SUM(ppa.Total_Amount_Allocated) AS total_amount_allocated ,
                                                    SUM(total_points_allocated) AS total_points_allocated
                                          FROM      Payment_Point_Allocation ppa ( NOLOCK )
                                          WHERE     Product_Type = 'AIR'
                                          GROUP BY  ppa.booking_ref ,
                                                    Product_ID ,
                                                    Product_Type ,
                                                    Pay_Allocation_ID
                                        ) bpp ON bpp.Product_ID = fd.flight_id
                        LEFT OUTER JOIN ( SELECT    COUNT(pax_id) No_of_Passenger ,
                                                    flight_id
                                          FROM      flight_passenger (NOLOCK)
                                          GROUP BY  flight_id
                                        ) fpp ON fpp.flight_id = fd.flight_id
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Credit_Amount_inc_Tax ,
                                                    Booking_Ref ,
                                                    ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103),
                                                           '--') Allocation_Date
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'Credit'
                                          GROUP BY  Booking_Ref ,
                                                    CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103)
                                        ) paCredit ON paCredit.Booking_Ref = ABR.Booking_Ref 
						--------------Recurrence start-------------------
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Credit_Amount_inc_Tax ,
                                                    Booking_Ref ,
                                                    ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103),
                                                           '--') Allocation_Date
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'RECURRENCY'
                                          GROUP BY  Booking_Ref ,
                                                    CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103)
                                        ) paRecCredit ON paRecCredit.Booking_Ref = ABR.Booking_Ref 
						----------------Recurrence end----------------- 
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Cash_Amount ,
                                                    Booking_Ref
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'Cash'
                                          GROUP BY  Booking_Ref
                                        ) paCash ON paCash.Booking_Ref = ABR.Booking_Ref
                        LEFT OUTER JOIN ( SELECT    flight_id ,
                                                    Status
                                          FROM      flight_segment_details (NOLOCK)
                                          GROUP BY  flight_id ,
                                                    Status
                                        ) fsd ON fsd.flight_id = fd.flight_id
                        OUTER APPLY ( SELECT    MAX(date_of_departure) date_of_departure
                                      FROM      flight_segment_details fsd ( NOLOCK )
                                      WHERE     start_segment = 1
                                                AND fsd.flight_id = fd.flight_id
                                      GROUP BY  start_segment
                                      HAVING    COUNT(start_segment) > 1
                                    ) fsd1
                        LEFT OUTER JOIN ( SELECT    Booking_Ref ,
                                                    Product_Type ,
                                                    product_booking_id ,
                                                    SUM(ISNULL(net_charge, 0)) gross_charge
                                          FROM      booking_charges (NOLOCK)
                                          WHERE     ISNULL(Status, 'OK') = 'OK'
                                          GROUP BY  Booking_Ref ,
                                                    Product_Type ,
                                                    product_booking_id
                                        ) bc ON bc.product_booking_id = fd.flight_id
                                                AND bc.Product_Type = 'AIR'
                WHERE   ABR.Company_id = @Company_Id
                UNION ALL

				--Hotel Code Start  
                SELECT  '0' Occurence ,
                        ABR.Booking_Ref AS Booking_Ref ,
                        ABR.Company_id AS Company_Id ,
                        ABR.affiliate_id ,
                        ISNULL(am.affiliate_code,
                               ( SELECT CASE WHEN ABR.branch_id = 1 THEN 'SBV'
                                             ELSE branch_name
                                        END
                                 FROM   dbo.company_branch _cb ( NOLOCK )
                                 WHERE  _cb.branch_id = ABR.branch_id
                               )) AS affiliate_code ,
                        ( SELECT    dbo.fn_GetSupplierNameNCode(1, 'A',
                                                              ABR.Booking_Ref,
                                                              @Company_Id,
                                                              NULL)
                        ) AS Supplier_Code ,
                        ( CASE WHEN sc.CountryCode = ( SELECT Business_Location
                                                       FROM   company (NOLOCK)
                                                       WHERE  Company_id = @Company_Id
                                                     ) THEN 'DOM'
                               ELSE 'INT'
                          END ) MarketType ,
                        LeadPaxName AS Lead_Pax ,
                        ISNULL(UPPER(ABR.Sales_Channel), '--') AS Sales_Channel ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, ABR.date_of_booking, 101), 103),
                               '--') Booking_Date ,
                        ISNULL(paCredit.Allocation_Date, '--') Allocation_Date ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, hb.check_in_date, 101), 103),
                               '--') Trip_Start_Date ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, hb.check_out_date, 101), 103),
                               '--') Trip_End_Date ,
                        CASE WHEN ISNULL(ABR.ClientCompanyCNPJ, '') <> ''
                             THEN ABR.ClientCompanyCNPJ
                             ELSE ISNULL(cm.CPF_No, '')
                        END CPF_No ,
                        'HHL' AS Product_Type ,
                        ISNULL(hb.pnr_no, '') AS PNR_No ,
                        ABR.destination AS City ,
                        '' State ,
                        ISNULL(ABR.Final_Status, '') Status ,
                        ISNULL(hp.No_of_Passenger, 0) No_of_Passenger ,
                        ( SELECT TOP ( 1 )
                                    Points_Conversion_Rate
                          FROM      Payment_Point_Allocation (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                        ) CPP ,
                        CASE WHEN bpp.total_amount_allocated > 0
                                  AND ( ( ISNULL(paCash.Cash_Amount, 0)
                                          + ISNULL(paCredit.Credit_Amount_inc_Tax,
                                                   0) ) > 0 )
                             THEN 'CASH+BONUS'
                             ELSE CASE WHEN bpp.total_amount_allocated > 0
                                       THEN 'BONUS'
                                       ELSE 'CASH'
                                  END
                        END payment_type ,
                        ( hb.net_rate - hb.ws_net_rate ) TransFee ,
                        CASE WHEN ISNULL(hb.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(hb.gross_cancellation_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(hb.ws_net_rate, 0)
                        END Net_Fare ,
                        CASE WHEN ISNULL(hb.status, 'OK') = 'CANCELLED' THEN 0
                             ELSE ISNULL(hb.tax, 0) + ISNULL(hb.TDS, 0)
                        END Gross_Tax ,
                        CASE WHEN ISNULL(hb.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(hb.gross_cancellation_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(hb.ws_net_rate, 0)
                                  + ISNULL(bc.gross_charge, 0) + ISNULL(hb.tax,
                                                              0)
                                  + ISNULL(hb.TDS, 0) + ISNULL(( hb.net_rate
                                                              - hb.ws_net_rate ),
                                                              0)
                        END Total_Gross_Fare ,
                        CASE WHEN ISNULL(hb.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(hb.gross_cancellation_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(hb.ws_net_rate, 0)
                                  + ISNULL(bc.gross_charge, 0) + ISNULL(hb.tax,
                                                              0)
                                  + ISNULL(hb.TDS, 0)
                        END Total_Net_Fare ,
                        '0' AS RAV ,
                        '0' AS SupplierFee ,
                        ISNULL(total_points_allocated, 0) BonusPoints ,
                        ( ISNULL(paCash.Cash_Amount, 0)
                          + ISNULL(paCredit.Credit_Amount_inc_Tax, 0) ) Total_Cash_Amount ,
                        hb.rate_of_exchange AS ROE ,
                        hb.property_name AS Itinerary_Type ,
                        CASE WHEN ISNULL(hb.status, '') = 'HK'
                             THEN 'Confirmed'
                             WHEN ISNULL(hb.status, '') = 'HX'
                             THEN 'Cancelled'
                             WHEN ISNULL(hb.status, '') = 'RQ'
                             THEN 'UnConfirmed'
                             ELSE ISNULL(hb.status, '')
                        END Itinerary_status ,
						--Discount
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Bonus'
                                    AND hb.hotel_booking_id = product_booking_id
                        ) AS Discount_Amount1 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Bonus'
                                    AND hb.hotel_booking_id = product_booking_id
                        ) AS Discount_Type1 ,
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount'
                                    AND hb.hotel_booking_id = product_booking_id
                        ) AS Discount_Amount2 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount'
                                    AND hb.hotel_booking_id = product_booking_id
                        ) AS Discount_Type2 ,
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Tax'
                                    AND hb.hotel_booking_id = product_booking_id
                        ) AS Discount_Amount3 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Tax'
                                    AND hb.hotel_booking_id = product_booking_id
                        ) AS Discount_Type3 ,
                        -- Discount
						ABR.branch_id
                FROM    #all_booking_ref ABR --INNER JOIN booking_master bm on bm.booking_ref=#all_booking_ref.Booking_Ref
                        INNER JOIN hotel_booking hb ( NOLOCK ) ON hb.Booking_Ref = ABR.Booking_Ref
                        INNER JOIN AgentName_VW agv ( NOLOCK ) ON ABR.Booking_Ref = agv.Booking_Ref
                        INNER JOIN client_master cm ( NOLOCK ) ON cm.client_id = ABR.client_id
                        LEFT OUTER JOIN Supplier_Master sm ( NOLOCK ) ON sm.Supplier_Id = hb.supplier_code
                        LEFT OUTER JOIN Affiliate_Master am ( NOLOCK ) ON am.affiliate_id = ABR.affiliate_id
                        LEFT OUTER JOIN ( SELECT    ppa.booking_ref ,
                                                    Product_ID ,
                                                    Product_Type ,
                                                    ppa.Pay_Allocation_ID ,
                                                    SUM(ppa.Total_Amount_Allocated) AS total_amount_allocated ,
                                                    SUM(total_points_allocated) AS total_points_allocated
                                          FROM      Payment_Point_Allocation ppa ( NOLOCK )
                                          WHERE     Product_Type = 'HHL'
                                          GROUP BY  ppa.booking_ref ,
                                                    Product_ID ,
                                                    Product_Type ,
                                                    Pay_Allocation_ID
                                        ) bpp ON bpp.Product_ID = hb.hotel_booking_id
                        LEFT OUTER JOIN ( SELECT    COUNT(pax_id) No_of_Passenger ,
                                                    hotel_booking_id
                                          FROM      hotel_passenger (NOLOCK)
                                          GROUP BY  hotel_booking_id
                                        ) hp ON hp.hotel_booking_id = hb.hotel_booking_id
                        LEFT OUTER JOIN ( SELECT    Allocation_Date ,
                                                    pay_allocation_id
                                          FROM      payment_allocation (NOLOCK)
                                        ) pa ON pa.pay_allocation_id = bpp.Pay_Allocation_ID
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Credit_Amount_inc_Tax ,
                                                    Booking_Ref ,
                                                    ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103),
                                                           '--') Allocation_Date
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'Credit'
                                          GROUP BY  Booking_Ref ,
                                                    CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103)
                                        ) paCredit ON paCredit.Booking_Ref = ABR.Booking_Ref 
						--------------Recurrence start-------------------
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Credit_Amount_inc_Tax ,
                                                    Booking_Ref ,
                                                    ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103),
                                                           '--') Allocation_Date
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'RECURRENCY'
                                          GROUP BY  Booking_Ref ,
                                                    CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103)
                                        ) paRecCredit ON paRecCredit.Booking_Ref = ABR.Booking_Ref 
						--------------Recurrence end------------------- 
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Cash_Amount ,
                                                    Booking_Ref
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'Cash'
                                          GROUP BY  Booking_Ref
                                        ) paCash ON paCash.Booking_Ref = ABR.Booking_Ref
                        LEFT OUTER JOIN XchangeAdmin.dbo.st_City sc ON sc.CityCode = hb.city_code
                        LEFT OUTER JOIN ( SELECT    Booking_Ref ,
                                                    Product_Type ,
                                                    product_booking_id ,
                                                    SUM(ISNULL(net_charge, 0)) gross_charge
                                          FROM      booking_charges (NOLOCK)
                                          WHERE     ISNULL(Status, 'OK') = 'OK'
                                          GROUP BY  Booking_Ref ,
                                                    Product_Type ,
                                                    product_booking_id
                                        ) bc ON bc.product_booking_id = hb.hotel_booking_id
                                                AND bc.Product_Type = 'HHL'
                WHERE   ABR.Company_id = @Company_Id
                UNION ALL
                SELECT  '0' Occurence ,
                        ABR.Booking_Ref AS Booking_Ref ,
                        ABR.Company_id AS Company_Id ,
                        ABR.affiliate_id ,
                        ISNULL(am.affiliate_code,
                               ( SELECT CASE WHEN ABR.branch_id = 1 THEN 'SBV'
                                             ELSE branch_name
                                        END
                                 FROM   dbo.company_branch _cb ( NOLOCK )
                                 WHERE  _cb.branch_id = ABR.branch_id
                               )) AS affiliate_code ,
                        ( SELECT    dbo.fn_GetSupplierNameNCode(1,
                                                              pb.product_code,
                                                              ABR.Booking_Ref,
                                                              @Company_Id, '')
                        ) AS Supplier_Code ,
                        ( CASE WHEN sc.CountryCode = ( SELECT Business_Location
                                                       FROM   company (NOLOCK)
                                                       WHERE  Company_id = @Company_Id
                                                     ) THEN 'DOM'
                               ELSE 'INT'
                          END ) MarketType ,
                        LeadPaxName AS Lead_Pax ,
                        ISNULL(UPPER(ABR.Sales_Channel), '--') AS Sales_Channel ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, ABR.date_of_booking, 101), 103),
                               '--') Booking_Date ,
                        ISNULL(paCredit.Allocation_Date, '--') Allocation_Date ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, pb.start_date, 101), 103),
                               '--') Trip_Start_Date ,
                        ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, pb.end_date, 101), 103),
                               '--') Trip_Start_Date ,
                        CASE WHEN ISNULL(ABR.ClientCompanyCNPJ, '') <> ''
                             THEN ABR.ClientCompanyCNPJ
                             ELSE ISNULL(cm.CPF_No, '')
                        END CPF_No ,
                        'OTH' Product_Type ,
                        ISNULL(pb.ConfirmationNumber, '') AS PNR_No ,
                        ABR.destination AS City ,
                        '' State ,
                        ISNULL(ABR.Final_Status, '''') Status ,
                        pb.number_of_pax AS No_of_Passenger ,
                        ( SELECT TOP ( 1 )
                                    points_conversion_rate
                          FROM      Payment_Point_Allocation (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                        ) CPP ,
                        CASE WHEN bpp.total_amount_allocated > 0
                                  AND ( ( ISNULL(paCash.Cash_Amount, 0)
                                          + ISNULL(paCredit.Credit_Amount_inc_Tax,
                                                   0) ) > 0 )
                             THEN 'CASH+BONUS'
                             ELSE CASE WHEN bpp.total_amount_allocated > 0
                                       THEN 'BONUS'
                                       ELSE 'CASH'
                                  END
                        END payment_type ,
                        ( SELECT    ISNULL(SUM(gross_charge), 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Airline Transfee'
                        ) TransFee ,
                        CASE WHEN ISNULL(pb.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(pb.gross_cancellation_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(pb.net_total, 0)
                        END Net_Fare ,
                        CASE WHEN ISNULL(pb.status, 'OK') = 'CANCELLED' THEN 0
                             ELSE ISNULL(pb.Tax, 0) + ISNULL(pb.TDS, 0)
                        END Gross_Tax ,
                        CASE WHEN ISNULL(pb.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(pb.gross_cancellation_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(pb.net_total, 0)
                                  + ISNULL(bc.gross_charge, 0) + ISNULL(pb.Tax,
                                                              0)
                                  + ISNULL(pb.TDS, 0)
                        END Total_Gross_Fare ,
                        CASE WHEN ISNULL(pb.status, 'OK') = 'CANCELLED'
                             THEN ISNULL(pb.gross_cancellation_charge, 0)
                                  + ISNULL(bc.gross_charge, 0)
                             ELSE ISNULL(pb.net_total, 0)
                                  + ISNULL(bc.gross_charge, 0) + ISNULL(pb.Tax,
                                                              0)
                                  + ISNULL(pb.TDS, 0)
                        END Total_Net_Fare ,
                        '0' RAV ,
                        '0' SupplierFee ,
                        ISNULL(total_points_allocated, 0) AS BonusPoints ,
                        ( ISNULL(paCash.Cash_Amount, 0)
                          + ISNULL(paCredit.Credit_Amount_inc_Tax, 0) ) Total_Cash_Amount ,
                        '0' AS ROE ,
                        '' Itinerary_Type ,
                        CASE WHEN pb.status = 'OK'
                                  OR pb.status = 'HK' THEN 'Confirmed'
                             WHEN pb.status = 'RQ' THEN 'UnConfirmed'
                             WHEN pb.status = 'HX' THEN 'Cancelled'
                             ELSE ISNULL(pb.status, '')
                        END Itinerary_status ,
						--Discount
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Bonus'
                                    AND pb.product_booking_id = product_booking_id
                        ) AS Discount_Amount1 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Bonus'
                                    AND pb.product_booking_id = product_booking_id
                        ) AS Discount_Type1 ,
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount'
                                    AND pb.product_booking_id = product_booking_id
                        ) AS Discount_Amount2 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount'
                                    AND pb.product_booking_id = product_booking_id
                        ) AS Discount_Type2 ,
                        ( SELECT    ISNULL(gross_charge, 0)
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Tax'
                                    AND pb.product_booking_id = product_booking_id
                        ) AS Discount_Amount3 ,
                        ( SELECT    ISNULL(charge_type, '')
                          FROM      booking_charges (NOLOCK)
                          WHERE     Booking_Ref = ABR.Booking_Ref
                                    AND charge_type = 'Discount on Tax'
                                    AND pb.product_booking_id = product_booking_id
                        ) AS Discount_Type3 ,
						-- Discount
                        ABR.branch_id
                FROM    #all_booking_ref ABR --INNER JOIN booking_master bm on bm.booking_ref=#all_booking_ref.Booking_Ref
                        INNER JOIN AgentName_VW agv ( NOLOCK ) ON ABR.Booking_Ref = agv.Booking_Ref
                        INNER JOIN product_bookings pb ( NOLOCK ) ON pb.Booking_Ref = ABR.Booking_Ref
                        INNER JOIN client_master cm ( NOLOCK ) ON cm.client_id = ABR.client_id
                        LEFT OUTER JOIN Affiliate_Master am ( NOLOCK ) ON am.affiliate_id = ABR.affiliate_id
                        LEFT OUTER JOIN XchangeAdmin.dbo.st_City sc ( NOLOCK ) ON sc.CityCode = pb.destination
                        LEFT OUTER JOIN ( SELECT    ppa.booking_ref ,
                                                    Product_ID ,
                                                    Product_Type ,
                                                    'BONUSPOINT' AS payment_type ,
                                                    Pay_Allocation_ID ,
                                                    SUM(ppa.Total_Amount_Allocated) AS total_amount_allocated ,
                                                    SUM(total_points_allocated) AS total_points_allocated ,
                                                    AVG(points_conversion_rate) points_conversion_rate
                                          FROM      Payment_Point_Allocation ppa ( NOLOCK )
                                          WHERE     Product_Type = 'OTH'
                                          GROUP BY  ppa.booking_ref ,
                                                    Product_ID ,
                                                    Product_Type ,
                                                    Pay_Allocation_ID
                                        ) bpp ON bpp.Product_ID = pb.product_booking_id
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Credit_Amount_inc_Tax ,
                                                    Booking_Ref ,
                                                    ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103),
                                                           '--') Allocation_Date
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'Credit'
                                          GROUP BY  Booking_Ref ,
                                                    CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103)
                                        ) paCredit ON paCredit.Booking_Ref = ABR.Booking_Ref  
						--------------Recurrence start-------------------
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Credit_Amount_inc_Tax ,
                                                    Booking_Ref ,
                                                    ISNULL(CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103),
                                                           '--') Allocation_Date
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'RECURRENCY'
                                          GROUP BY  Booking_Ref ,
                                                    CONVERT(VARCHAR(10), CONVERT(DATETIME, Allocation_Date, 101), 103)
                                        ) paRecCredit ON paRecCredit.Booking_Ref = ABR.Booking_Ref  
						--------------Recurrence end-------------------
                        LEFT OUTER JOIN ( SELECT    SUM(allocated_amount) Cash_Amount ,
                                                    Booking_Ref
                                          FROM      payment_allocation (NOLOCK)
                                          WHERE     payment_mode = 'Cash'
                                          GROUP BY  Booking_Ref
                                        ) paCash ON paCash.Booking_Ref = ABR.Booking_Ref
                        LEFT OUTER JOIN ( SELECT    Booking_Ref ,
                                                    Product_Type ,
                                                    product_booking_id ,
                                                    SUM(ISNULL(net_charge, 0)) gross_charge
                                          FROM      booking_charges (NOLOCK)
                                          WHERE     ISNULL(Status, 'OK') = 'OK'
                                          GROUP BY  Booking_Ref ,
                                                    Product_Type ,
                                                    product_booking_id
                                        ) bc ON bc.product_booking_id = pb.product_booking_id
                                                AND bc.Product_Type = 'OTH'
                WHERE   ABR.Company_id = @Company_Id

		--insertion end
        DECLARE @BookingCount INT  
			,	@ItineraryCount INT  
			,	@BookingNo INT= 1
        
		DECLARE @tmptblBooking TABLE
            (
              ID INT IDENTITY(1, 1) ,
              Booking_Ref VARCHAR(20) ,
              occurrence INT
            )

        INSERT  @tmptblBooking
                ( Booking_Ref ,
                  occurrence
                )
                SELECT  Booking_Ref ,
                        COUNT(*) occurence
                FROM    #tmptbl
                GROUP BY Booking_Ref

        DECLARE @TempItineraryNo INT= 1
			,	@TempItineraryCount INT

        SELECT  @TempItineraryCount = COUNT(*)
        FROM    @tmptblBooking

        CREATE TABLE #tmptblItineraryOccurence
            (
              RowID INT IDENTITY(1, 1) ,
              Id INT
            )

        WHILE @TempItineraryNo <= @TempItineraryCount
            BEGIN
                TRUNCATE TABLE #tmptblItineraryOccurence
                
				INSERT  #tmptblItineraryOccurence
                        ( Id )
                SELECT  Id
                FROM    #tmptbl
                WHERE   Booking_Ref = ( SELECT  Booking_Ref
                                        FROM    @tmptblBooking
                                        WHERE   ID = @TempItineraryNo
                                        )

                DECLARE @Occurence INT= ( SELECT    COUNT(*)
                                          FROM      #tmptblItineraryOccurence
                                        )
					,	@occurenceNo INT= 1

                WHILE @occurenceNo <= @Occurence
                    BEGIN
                        UPDATE  #tmptbl
                        SET     Occurence = @occurenceNo
                        WHERE   Id = ( SELECT   Id
                                       FROM     #tmptblItineraryOccurence
                                       WHERE    RowID = @occurenceNo
                                     )

                        SET @occurenceNo = @occurenceNo + 1
                    END

                SET @TempItineraryNo = @TempItineraryNo + 1
            END

		--Code to add Occurence in CC_Info
        DECLARE @tmptblCC_Info TABLE
            (
              ID INT IDENTITY(1, 1) ,
              Booking_Ref VARCHAR(20) ,
              occurrence INT
            )

        INSERT  @tmptblCC_Info
                ( Booking_Ref ,
                  occurrence
                )
                SELECT  Booking_Ref ,
                        COUNT(*) occurence
                FROM    #Credit_Info
                GROUP BY Booking_Ref

        DECLARE @TempItnNo INT= 1
			,	@TempItnCount INT

        SELECT  @TempItnCount = COUNT(*)
        FROM    @tmptblCC_Info

        CREATE TABLE #tmptblCC_InfoOccurence
            (
              RowID INT IDENTITY(1, 1) ,
              Id INT
            )

        WHILE @TempItnNo <= @TempItnCount
            BEGIN
                TRUNCATE TABLE #tmptblCC_InfoOccurence

                INSERT  #tmptblCC_InfoOccurence
                        ( Id )
                SELECT  Id
                FROM    #Credit_Info
                WHERE   Booking_Ref = ( SELECT  Booking_Ref
                                        FROM    @tmptblCC_Info
                                        WHERE   ID = @TempItnNo
                                        )

                DECLARE @CCOccurence INT= ( SELECT  COUNT(*)
                                            FROM    #tmptblCC_InfoOccurence
                                          )
					,	@CCoccurenceNo INT= 1

                WHILE @CCoccurenceNo <= @CCOccurence
                    BEGIN
                        UPDATE  #Credit_Info
                        SET     Occurence = @CCoccurenceNo
                        WHERE   Id = ( SELECT   Id
                                       FROM     #tmptblCC_InfoOccurence
                                       WHERE    RowID = @CCoccurenceNo
                                     )

                        SET @CCoccurenceNo = @CCoccurenceNo + 1
                    END

                SET @TempItnNo = @TempItnNo + 1
            END

		--Code ends for adding occurence in Cc_info

		--******** Code to add Occurence in Recurr_Info
        DECLARE @tmptblRR_Info TABLE
            (
              ID INT IDENTITY(1, 1) ,
              Booking_Ref VARCHAR(20) ,
              occurrence INT
            )

        INSERT  @tmptblRR_Info
                ( Booking_Ref ,
                  occurrence
                )
                SELECT  Booking_Ref ,
                        COUNT(*) occurence
                FROM    #Recurr_Info
                GROUP BY Booking_Ref

        DECLARE @TempItnNorr INT= 1
			,	@TempItnCountrr INT
        
		SELECT  @TempItnCountrr = ( SELECT  COUNT(*)
                                    FROM    @tmptblRR_Info
                                  )

        CREATE TABLE #tmptblRR_InfoOccurence
            (
              RowID INT IDENTITY(1, 1) ,
              Id INT
            )

        WHILE @TempItnNorr <= @TempItnCountrr
            BEGIN
                TRUNCATE TABLE #tmptblRR_InfoOccurence
                
				INSERT  #tmptblRR_InfoOccurence
                        ( Id )
                SELECT  Id
                FROM    #Recurr_Info
                WHERE   Booking_Ref = ( SELECT  Booking_Ref
                                        FROM    @tmptblRR_Info
                                        WHERE   ID = @TempItnNorr
                                        )

                DECLARE @RROccurence INT= ( SELECT  COUNT(*)
                                            FROM    #tmptblRR_InfoOccurence
                                          )
					,	@RRoccurenceNo INT= 1
       
                WHILE @RRoccurenceNo <= @RROccurence
                    BEGIN
                        UPDATE  #Recurr_Info
                        SET     Occurence = @RRoccurenceNo
                        WHERE   Id = ( SELECT   Id
                                       FROM     #tmptblRR_InfoOccurence
                                       WHERE    RowID = @RRoccurenceNo
                                     )
                        SET @RRoccurenceNo = @RRoccurenceNo + 1
                    END
                SET @TempItnNorr = @TempItnNorr + 1
            END
		--****** Code Ends

		-- Loop for All Bookings
        SELECT  @BookingCount = COUNT(*)
        FROM    #all_booking_ref

        WHILE @BookingNo <= @BookingCount
            BEGIN
                DECLARE @ItineraryNo INT= 1
                SELECT  @ItineraryCount = COUNT(*)
                FROM    #tmptbl
                WHERE   Booking_Ref = ( SELECT  Booking_Ref
                                        FROM    #all_booking_ref
                                        WHERE   RecordId = @BookingNo
                                      )

		--Loop for all Itineraries in a booking ref
        WHILE @ItineraryNo <= @ItineraryCount
			BEGIN
				IF ( @ItineraryNo < 5 )
                    BEGIN
						DECLARE @SqlQuery VARCHAR(MAX)= 'update #all_product set Company_id=tt.Company_Id,  branch_id=tt.branch_id,
	  Affiliate_Id=tt.affiliate_id,
      Product= (Case when #all_product.Product is null then tt.Product_Type else #all_product.Product +''+''+ tt.Product_Type End),
      CPF_No=tt.CPF_No,Allocation_Date=tt.Allocation_Date,Trip_Start_Date=tt.Trip_Start_Date,
      Trip_End_Date=tt.Trip_End_Date,City=tt.City,No_of_Passenger=tt.No_of_Passenger,
      MarketType=tt.MarketType,
      Sales_Channel=tt.Sales_Channel,
      CPP=tt.CPP,payment_type=tt.payment_type,Lead_Pax=tt.Lead_Pax,State=tt.State,Status=tt.Status,
      Supplier_Code' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '=tt.Supplier_Code,
      --PNR_No' + CONVERT(VARCHAR(10), @ItineraryNo) + '=tt.PNR_No,
      --PNR_No' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN tt.PNR_No ELSE
      --(select top 1 PNR_No from #tmptbl where id> tt.id and (Itn_Status<>''CANCELLED'' and Len(tt.PNR_No)>0)) END),
      PNR_No' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN
      ( case when (select top 1 UPPER(Itn_Status) from #tmptbl where id=((tt.id)-1))=''CANCELLED'' then '''' else tt.PNR_No end)
      ELSE
      ( case when (select top 1 UPPER(Itn_Status) from #tmptbl where id=((tt.id)-1))=''CANCELLED'' then '''' else
      (select top 1 PNR_No from #tmptbl where id> tt.id and (Itn_Status<>''CANCELLED'' and Len(tt.PNR_No)>0)) end)END),
      --PNR_No' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN tt.PNR_No ELSE
      --(select top 1 PNR_No from #tmptbl where id=(tt.id+1) and Itn_Status<>''CANCELLED'') END),
      --NetRate' + CONVERT(VARCHAR(10), @ItineraryNo) + '=tt.Net_Fare,
      --NetRate' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN tt.Net_Fare ELSE
      --(select top 1 Net_Fare from #tmptbl where id> tt.id and (Itn_Status<>''CANCELLED'' and Len(tt.PNR_No)>0)) END),
      NetRate' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN
      ( case when (select top 1 UPPER(Itn_Status) from #tmptbl where id=((tt.id)-1))=''CANCELLED'' then ''0'' else tt.Net_Fare end)
      ELSE
      ( case when (select top 1 UPPER(Itn_Status) from #tmptbl where id=((tt.id)-1))=''CANCELLED'' then ''0'' else
      (select top 1 Net_Fare from #tmptbl where id> tt.id and (Itn_Status<>''CANCELLED'' and Len(tt.PNR_No)>0)) end)END),
      Supplier_Fee' + CONVERT(VARCHAR(10), @ItineraryNo) + '=tt.SupplierFee,
      Trans_Fee' + CONVERT(VARCHAR(10), @ItineraryNo) + '=tt.TransFee,
      --Itn_Status' + CONVERT(VARCHAR(10), @ItineraryNo) + '=tt.Itn_Status,
      --Itn_Status' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN tt.Itn_Status ELSE         --(select top 1 Itn_Status from #tmptbl where id> tt.id and (Itn_Status<>''CANCELLED'' and Len(tt.PNR_No)>0)) END),
      --Itn_Status' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN tt.Itn_Status ELSE
      --(select top 1 Itn_Status from #tmptbl where id> tt.id and (Itn_Status<>''CANCELLED'' and Len(tt.PNR_No)>0)) END),
      Itn_Status' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + '= (CASE WHEN tt.Itn_Status <>''CANCELLED'' THEN
      ( case when (select top 1 UPPER(Itn_Status) from #tmptbl where id=((tt.id)-1))=''CANCELLED'' then '''' else tt.Itn_Status end)
      ELSE
      ( case when (select top 1 UPPER(Itn_Status) from #tmptbl where id=((tt.id)-1))=''CANCELLED'' then '''' else
      (select top 1 Itn_Status from #tmptbl where id> tt.id and (Itn_Status<>''CANCELLED'' and Len(tt.PNR_No)>0)) end)END),
      Cash=tt.Total_Cash_Amount,
	  Bonus_Points=(Case when Tax is null then tt.BonusPoints else #all_product.Bonus_Points + tt.BonusPoints End),
	  RAV=(Case when Tax is null then tt.RAV else #all_product.RAV + tt.RAV End),
      Tax=(Case when Tax is null then tt.Gross_Tax else #all_product.Tax + tt.Gross_Tax End),
      Hotel_Exchange_Rate=tt.ROE,
      Total_Value_Supplier=(Case when Total_Value_Supplier is null then tt.Total_Net_Fare else #all_product.Total_Value_Supplier + tt.Total_Net_Fare End),
      Total_Value_Charged=(Case when Total_Value_Charged is null then tt.Total_Gross_Fare else #all_product.Total_Value_Charged + tt.Total_Gross_Fare End),
      Itinerary_Detail=(Case when Itinerary_Detail is null then tt.Itinerary_Type else Itinerary_Detail +''/''+tt.Itinerary_Type End),
      Discount_Amount1=tt.Discount_Amount1,Discount_Type1=tt.Discount_Type1,Discount_Amount2=tt.Discount_Amount2,
      Discount_Type2=tt.Discount_Type2,Discount_Amount3=tt.Discount_Amount3,Discount_Type3=tt.Discount_Type3
      from (select * from #tmptbl
			where Booking_Ref=(select Booking_Ref from #all_booking_ref where RecordId='
                                    + CONVERT(VARCHAR(10), @BookingNo)
                                    + ') and
			Occurence=' + CONVERT(VARCHAR(10), @ItineraryNo)
                                    + ')tt where #all_product.Booking_Ref=tt.Booking_Ref'
      END  
        
		EXEC (@SqlQuery)
        
		SET @ItineraryNo = @ItineraryNo + 1
    END

   --Loop For Inserting CC Details
   --select * from #Credit_Info

        DECLARE @CCCount INT= 0  
			,	@CCNo INT= 1  

        SELECT  @CCCount =(	SELECT COUNT(*)
							FROM   #Credit_Info
                            WHERE  Booking_Ref = (	SELECT	Booking_Ref
                                                    FROM	#all_booking_ref
                                                    WHERE	RecordId = @BookingNo )
                            )

		WHILE @CCNo <= @CCCount
			BEGIN
				DECLARE @SqlQuery1 VARCHAR(MAX)= 'update #all_product set CC_Amount'
                            + CONVERT(VARCHAR(10), @CCNo) + '=cc.CC_Amount,
								Installment_Amount' + CONVERT(VARCHAR(10), @CCNo)
                            + '=(Case when cc.Installment_Amount=cc.CC_Amount then ''0'' else cc.Installment_Amount End),
								Trans_ID' + CONVERT(VARCHAR(10), @CCNo) + '=cc.Trans_ID,
								CC_Company' + CONVERT(VARCHAR(10), @CCNo)
                            + '=cc.CC_Company   
							from (select * from #Credit_Info where Booking_Ref=(select Booking_Ref from #all_booking_ref where RecordId='
                            + CONVERT(VARCHAR(10), @BookingNo)
                            + ') and Occurence=' + CONVERT(VARCHAR(10), @CCNo)
                            + ')cc
							where #all_product.Booking_Ref=cc.Booking_Ref'

                EXEC (@SqlQuery1)

				SET @CCNo = @CCNo + 1
            END

	-------************************

	--Loop For Inserting CC Details  
	--select * from #Recurr_Info

		DECLARE @RecurrenceCCCount INT= 0
            ,	@RecurrenceCCNo INT= 1
        
		SELECT  @RecurrenceCCCount = (	SELECT   COUNT(*)
                                        FROM     #Recurr_Info
                                        WHERE    Booking_Ref =( SELECT	Booking_Ref
																FROM	#all_booking_ref
																WHERE	RecordId = @BookingNo
                                                              )
                                    )

        WHILE @RecurrenceCCNo <= @RecurrenceCCCount
            BEGIN
				DECLARE @SqlQuery11 VARCHAR(MAX)= 'update #all_product set CC_AmountRecurrence'
                            + CONVERT(VARCHAR(10), @RecurrenceCCNo)
                            + '=cc1.CC_Amount,
								Installment_AmountRecurrence' + CONVERT(VARCHAR(10), @RecurrenceCCNo)
                            + '=(Case when cc1.Installment_Amount=cc1.CC_Amount then ''0'' else cc1.Installment_Amount End),  
								Trans_IDRecurrence' + CONVERT(VARCHAR(10), @RecurrenceCCNo)
                            + '=cc1.Trans_ID,
								CC_Company' + CONVERT(VARCHAR(10), @RecurrenceCCNo)
                            + '=cc1.CC_Company
							from (select * from #Recurr_Info where Booking_Ref=(select Booking_Ref from #all_booking_ref where RecordId='
                            + CONVERT(VARCHAR(10), @BookingNo)
                            + ') and Occurence='
                            + CONVERT(VARCHAR(10), @RecurrenceCCNo) + ')cc1
							where #all_product.Booking_Ref=cc1.Booking_Ref'

                EXEC (@SqlQuery11)
                
				SET @RecurrenceCCNo = @RecurrenceCCNo + 1
            END
	
	-----*************************
            SET @BookingNo = @BookingNo + 1
        END

        IF ISNULL(@Booking_ref, '') = ''
            BEGIN
                INSERT  INTO FATO_Records
                SELECT  *
                FROM    #all_product
            END
        ELSE
            BEGIN
                UPDATE  FATO_Records WITH(ROWLOCK)
                SET     Booking_Ref = AP.Booking_Ref ,
                        Company_id = AP.Company_id ,
                        Affiliate_Id = AP.Affiliate_Id ,
                        Product = AP.Product ,
                        CPP = AP.CPP ,
                        CPF_No = AP.CPF_No ,
                        Booking_Date = AP.Booking_Date ,
                        Allocation_Date = AP.Allocation_Date ,
                        Trip_Start_Date = AP.Trip_Start_Date ,
                        MarketType = AP.MarketType ,
                        Trip_End_Date = AP.Trip_End_Date ,
                        No_of_Passenger = AP.No_of_Passenger ,
                        Sales_Channel = AP.Sales_Channel ,
                        payment_type = AP.payment_type ,
                        Lead_Pax = AP.Lead_Pax ,
                        Status = AP.Status ,
                        Supplier_Code1 = AP.Supplier_Code1 ,
                        Supplier_Code2 = AP.Supplier_Code2 ,
                        Supplier_Code3 = AP.Supplier_Code3 ,
                        Supplier_Code4 = AP.Supplier_Code4 ,
                        PNR_No1 = AP.PNR_No1 ,
                        PNR_No2 = AP.PNR_No2 ,
                        PNR_No3 = AP.PNR_No3 ,
                        PNR_No4 = AP.PNR_No4 ,
                        Itinerary_Detail = AP.Itinerary_Detail ,
                        Hotel_Exchange_Rate = AP.Hotel_Exchange_Rate ,
                        NetRate1 = AP.NetRate1 ,
                        NetRate2 = AP.NetRate2 ,
                        NetRate3 = AP.NetRate3 ,
                        NetRate4 = AP.NetRate4 ,
                        Tax = AP.Tax ,
                        RAV = AP.RAV ,
                        Supplier_Fee1 = AP.Supplier_Fee1 ,
                        Supplier_Fee2 = AP.Supplier_Fee2 ,
                        Supplier_Fee3 = AP.Supplier_Fee3 ,
                        Supplier_Fee4 = AP.Supplier_Fee4 ,
                        Trans_Fee1 = AP.Trans_Fee1 ,
                        Trans_Fee2 = AP.Trans_Fee2 ,
                        Trans_Fee3 = AP.Trans_Fee3 ,
                        Trans_Fee4 = AP.Trans_Fee4 ,
                        Total_Value_Supplier = AP.Total_Value_Supplier ,
                        Total_Value_Charged = AP.Total_Value_Charged ,
                        Bonus_Points = AP.Bonus_Points ,
                        Cash = AP.Cash ,
                        CC_Amount1 = AP.CC_Amount1 ,
                        Installment_Amount1 = AP.Installment_Amount1 ,
                        Trans_ID1 = AP.Trans_ID1 ,
                        CC_Amount2 = AP.CC_Amount2 ,
                        Installment_Amount2 = AP.Installment_Amount2 ,
                        Trans_ID2 = AP.Trans_ID2 ,
                        CC_Amount3 = AP.CC_Amount3 ,
                        Installment_Amount3 = AP.Installment_Amount3 ,
                        Trans_ID3 = AP.Trans_ID3 ,
                        CC_Amount4 = AP.CC_Amount4 ,
                        Installment_Amount4 = AP.Installment_Amount4 ,
                        Trans_ID4 = AP.Trans_ID4 , 
						-----------Recurrence start---------------------
                        CC_AmountRecurrence1 = AP.CC_AmountRecurrence1 ,
                        Installment_AmountRecurrence1 = AP.Installment_AmountRecurrence1 ,
                        Trans_IDRecurrence1 = AP.Trans_IDRecurrence1 ,
                        CC_AmountRecurrence2 = AP.CC_AmountRecurrence2 ,
                        Installment_AmountRecurrence2 = AP.Installment_AmountRecurrence2 ,
                        Trans_IDRecurrence2 = AP.Trans_IDRecurrence2 ,
                        CC_AmountRecurrence3 = AP.CC_AmountRecurrence3 ,
                        Installment_AmountRecurrence3 = AP.Installment_AmountRecurrence3 ,
                        Trans_IDRecurrence3 = AP.Trans_IDRecurrence3 ,
                        CC_AmountRecurrence4 = AP.CC_AmountRecurrence4 ,
                        Installment_AmountRecurrence4 = AP.Installment_AmountRecurrence4 ,
                        Trans_IDRecurrence4 = AP.Trans_IDRecurrence4 ,  
						----------------Recurrence end--------------
						------- Discount -----------
                        Discount_Amount1 = AP.Discount_Amount1 ,
                        Discount_Amount2 = AP.Discount_Amount2 ,
                        Discount_Amount3 = AP.Discount_Amount3 ,
                        Discount_Type1 = AP.Discount_Type1 ,
                        Discount_Type2 = AP.Discount_Type2 ,
                        Discount_Type3 = AP.Discount_Type3 , 
						------- Discount End ----------- 
                        Itn_Status1 = AP.Itn_Status1 ,
                        Itn_Status2 = AP.Itn_Status2 ,
                        Itn_Status3 = AP.Itn_Status3 ,
                        Itn_Status4 = AP.Itn_Status4 ,
                        CC_Company1 = AP.CC_Company1 ,
                        CC_Company2 = AP.CC_Company2 ,
                        CC_Company3 = AP.CC_Company3 ,
                        CC_Company4 = AP.CC_Company4 ,
                        Change_Status = 0 ,
                        branch_id = AP.branch_id
                FROM    ( SELECT    *
                          FROM      #all_product
                        ) AS AP
                WHERE   FATO_Records.Booking_Ref = @Booking_ref
            END  
        SET FMTONLY ON
    END  
GO
