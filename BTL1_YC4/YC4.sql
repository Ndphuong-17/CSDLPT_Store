----1. Câu truy vấn đơn giản
----Câu truy vấn trên nhằm lấy ra mã sản phẩm (INV.PRODUCT_ID), số lượng tồn kho (INV.QUANTITY), màu của sản phẩm (PROD.COLOR), giá mua vào (S.COST_PRICE2) và bậc thành phố nơi phân phối (DC.CITY_LEVEL)  với các loại sản phẩm dành cho nữ tồn kho còn trên 5 sản phẩm (INV.QUANTITY > 5), có giá mua dưới 1 triệu(S.NET_PRICE < 1000000) và được lưu trong kho có mã STORE = "1201"

SELECT DISTINCT INV.PRODUCT_ID, INV.QUANTITY, PROD.COLOR, S.COST_PRICE2, DC.CITY_LEVEL
FROM INVENTORY@CN01_DBLINK INV, PRODUCT@CN01_DBLINK PROD, DISTRIBUTIONCHANNEL@CN01_DBLINK DC, SALE@CN01_DBLINK S
WHERE INV.PRODUCT_ID = PROD.PRODUCT_ID AND INV.STORE = DC.SITE_STORE
  AND S.PRODUCT_ID = PROD.PRODUCT_ID
  AND INV.STORE = 1201 AND INV.QUANTITY > 5
  AND PROD.GENDER = 'WOM' AND S.NET_PRICE < 1000000;

----2. EXPLAIN QUERY câu truy vấn đơn giản

SELECT /*+ GATHER_PLAN_STATISTICS */ DISTINCT INV.PRODUCT_ID, INV.QUANTITY, PROD.COLOR, S.COST_PRICE2, DC.CITY_LEVEL, 
FROM INVENTORY INV, PRODUCT PROD, DISTRIBUTIONCHANNEL DC, SALE S
WHERE INV.PRODUCT_ID = PROD.PRODUCT_ID AND INV.STORE = DC.SITE_STORE
  AND S.PRODUCT_ID = PROD.PRODUCT_ID
  AND INV.STORE = "1201" AND INV.QUANTITY > 5
  AND PROD.GENDER = 'WOM’' AND S.NET_PRICE < 1000000;

SELECT * FROM 
TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));

---- 3. Viết lại câu query trên môi trường phân tán. Truy vấn tại site CN1 (INV.STORE = "1201")
SELECT DISTINCT g.product_id, g.quantity, g.color, g.cost_price2, g.city_level
FROM
    (
        SELECT e.product_id, e.quantity, e.color, e.cost_price2, e.store, f.city_level
        FROM
            (
                SELECT c.product_id, c.quantity, c.color, c.store, d.cost_price2
                FROM
                    (
                        SELECT a.product_id, a.quantity, a.store, b.color
                        FROM 
                            (
                                SELECT inv.product_id, inv.quantity, inv.store
                                FROM inventory inv
                                WHERE inv.quantity > 5
                            ) a
                            INNER JOIN 
                            (
                                SELECT pro.product_id, pro.color as color
                                FROM product pro
                                WHERE pro.gender = 'WOM'
                            ) b
                            ON b.product_id = a.product_id          
                    ) c
                    INNER JOIN 
                    (
                        SELECT s.cost_price2, s.product_id
                        FROM sale s
                        WHERE s.net_price < 1000000
                    ) d 
                    ON c.product_id = d.product_id
            ) e
            INNER JOIN 
            (
                SELECT dc.city_level, dc.site_store
                FROM distributionchannel dc
            ) f 
            ON e.store = f.site_store
    ) g;
