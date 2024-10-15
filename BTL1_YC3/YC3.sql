DECLARE
trans_id VARCHAR2(100);
begin
trans_id :=dbms_transaction.local_transaction_id( TRUE );
END;
//Kiểm tra mức cô lập

select s.sid, s.serial#,
case BITAND(t.flag,power(2, 28))
When 0 then 'read committed'
else 'Serializable'
end as isolation_level
from v$transaction t
join v$session s on t.addr = s.taddr;

alter session set ISOLATION_LEVEL=SERIALIZABLE;
alter session set ISOLATION_LEVEL=Read COMMITTED;

commit;

INSERT INTO "C##CN02"."PRODUCT" (PRODUCT_ID, COLOR, GENDER, PRODUCT_GROUP, SIZE_PRODUCT) VALUES ('SPNEW2', 'DEN', 'BOY', 'SAN', '35')

Select * from product where product.product_id= 'SP001DEN42';

Update PRODUCT  SET COLOR='DEN' where product_id= 'SP001DEN42';