-- CAU1: Tìm số lượng còn từ chi nhánh chính của các sản phẩm
select inventory.product_id as "Mã sản phẩm" , quantity as "Số lượng còn"
from INVENTORY@CN01_DBLINK join PRODUCT@CN01_DBLINK
on inventory.product_id = product.product_id
where product.gender = 'WOM';

-- cau2: Xuất ra thông tin nhữnng sandal cho trẻ em có size 34 còn hàng từ chi nhánh chính
select * 
from PRODUCT@CN01_DBLINK join inventory@CN01_DBLINK
on inventory.product_id = product.product_id
where (product.gender = 'GIR' or product.gender = 'boy')
and product.size_product = 34
and product.product_group = 'SAN';

-- cau3:Tìm tổng lượng sản phẩm sandal cho trẻ em có size 34 còn trong kho ở chi nhánh 1 và 2
select sum(TONGSL)from(
select sum(I.quantity) as TONGSL
from product P join inventory I
on I.product_id = P.product_id
where (P.gender = 'GIR' or P.gender = 'boy')
and P.size_product = 34
and P.product_group = 'SAN'
UNION ALL
select sum(I2.quantity) as TONGSL
from product@LINK_CN02 P2 join inventory@LINK_CN02 I2
on I2.product_id = P2.product_id
where (P2.gender = 'GIR' or P2.gender = 'boy')
and P2.size_product = 34
and P2.product_group = 'SAN');

--cau4: Sản phẩm không còn kinh doanh
select *
from product@CN01_DBLINK
where product.product_id not in (
    select inventory.product_id
    from inventory
);

--cau5: Những sản phẩm chỉ bán CN01 không có ở CN02
select s.product_id
from INVENTORY S
where S.product_id not in (
    select  S2.product_id
    from INVENTORY@LINK_CN02 S2
);

--cau6: Sản phẩm đã được bán ở chi nhánh 1 và chi nhánh 2
SELECT *
FROM product@CN01_DBLINK P1
WHERE EXISTS (
    SELECT *
    FROM distributionchannel@CN01_DBLINK D1
    WHERE D1.Site_STORE = 1201 
       AND EXISTS (
           SELECT *
           FROM sale
           WHERE sale.product_id = P1.product_id
           AND sale.store = D1.site_store
       )
       AND EXISTS (
           SELECT *
           FROM sale@LINK_CN02 S2
           WHERE S2.product_id = P1.product_id
           AND S2.store = D1.site_store
       )
) AND NOT EXISTS (
    SELECT *
    FROM distributionchannel@CN01_DBLINK D1
    WHERE D1.Site_STORE IN (1201, 1202)
       AND NOT EXISTS (
           SELECT *
           FROM sale
           WHERE sale.product_id = P1.product_id
           AND sale.store = D1.site_store
       )
       AND NOT EXISTS (
           SELECT *
           FROM sale@LINK_CN02 S2
           WHERE S2.product_id = P1.product_id
           AND S2.store = D1.site_store
       )
);

--Cau7: Nhung san pham chi ban duoc o Chi nhánh 1 
select *
from SALE S
where  S.product_id not in (
    select  S1.product_id
    from SALE@CN01_DBLINK S1
    where S1.store = 1202
    or  S1.store = 1203 or S1.store=1204
);

--Cau8: Nhung san pham ban nhieu hon 1 lan ở chi nhánh 1 và 2
SELECT product_id
FROM (
    SELECT *
    FROM sale 
    UNION ALL
    SELECT *
    FROM sale@LINK_CN02 S2
) 
GROUP BY product_id
HAVING COUNT(sale_ID) > 1;

--Cau9: Tinh loi nhuan thu duoc theo tung san pham o CN01 và CN02
select product_id, sum(DoanhThu) from(
select product_id, sum(sale.net_price*sale.sold_quantity -sale.cost_price2*sale.sold_quantity) as DoanhThu
from sale
GROUP BY product_id
UNION ALL
select S2.product_id, sum(S2.net_price*S2.sold_quantity -S2.cost_price2*S2.sold_quantity) as DoanhThu
from sale@LINK_CN02 S2
GROUP BY S2.product_id)
GROUP BY product_id;

--Cau10: Cua hang co loi nhuan cao nhat
select S.store, sum(S.net_price*S.sold_quantity -S.cost_price2*S.sold_quantity) as DoanhThu
from sale@CN01_DBLINK S
GROUP BY S.store
ORDER BY DoanhThu DESC
FETCH FIRST 1 ROW ONLY;
                         