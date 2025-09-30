SELECT 
    lc.COMPANY_SHORT_NAME AS SBU,
    lb.SHORT_NAME AS BUYER,
    bb.BRAND_NAME AS BUYER_BRAND,
    wpdm.JOB_NO, 
    SUM(wpcsb.ORDER_QUANTITY) AS ORDER_QTY,
    ('$' || SUM(wpcsb.ORDER_TOTAL)) AS FOB_VALUE,
    
    -- Mapping EMB_NAME based on the numeric codes
    CASE 
        WHEN pecd.EMB_NAME = 1 THEN 'Printing'
        WHEN pecd.EMB_NAME = 2 THEN 'Embroidery'
        WHEN pecd.EMB_NAME = 3 THEN 'Wash'
        WHEN pecd.EMB_NAME = 4 THEN 'Special Works'
        WHEN pecd.EMB_NAME = 5 THEN 'Gmts Dyeing'
        WHEN pecd.EMB_NAME = 6 THEN 'Attachment'
        WHEN pecd.EMB_NAME = 99 THEN 'Others'
        ELSE 'Unknown'  
    END AS EMB_NAME,

    pecd.RATE,

    -- Calculate EMB Value as ORDER_QUANTITY * RATE
    SUM(wpcsb.ORDER_QUANTITY * pecd.RATE) AS EMB_VALUE  

FROM 
    WO_PO_DETAILS_MASTER wpdm
JOIN 
    WO_PO_BREAK_DOWN wpbd ON wpdm.JOB_NO = wpbd.JOB_NO_MST
JOIN 
    LIB_BUYER lb ON wpdm.BUYER_NAME = lb.ID
JOIN 
    LIB_COMPANY lc ON wpdm.COMPANY_NAME = lc.ID
LEFT JOIN 
    LIB_BUYER_BRAND bb ON wpdm.BRAND_ID = bb.ID
LEFT JOIN
    WO_PO_COLOR_SIZE_BREAKDOWN wpcsb ON wpdm.JOB_NO = wpcsb.JOB_NO_MST
LEFT JOIN 
    WO_PRE_COST_EMBE_COST_DTLS pecd ON wpdm.JOB_NO = pecd.JOB_NO  
WHERE 
    wpdm.Is_deleted = 0
    AND wpdm.status_active = 1
    AND wpbd.Is_deleted = 0
    AND wpbd.status_active = 1
    AND lc.ID IN (1, 2)
    AND pecd.RATE IS NOT NULL  
    AND pecd.RATE > 0          
GROUP BY 
    lc.COMPANY_SHORT_NAME,
    lb.SHORT_NAME, 
    bb.BRAND_NAME, 
    wpdm.JOB_NO,
    pecd.EMB_NAME,
    pecd.RATE  
ORDER BY 
    wpdm.JOB_NO;
