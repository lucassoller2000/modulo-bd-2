DECLARE vIDPEDIDO PEDIDO.IDPEDIDO%TYPE := 8420; vDATAENTREGA PEDIDO.DATAENTREGA%TYPE; vVALORPEDIDO PEDIDO.VALORPEDIDO%TYPE;
BEGIN
    SELECT DATAENTREGA, VALORPEDIDO INTO vDATAENTREGA, vVALORPEDIDO FROM PEDIDO WHERE IDPEDIDO = vIDPEDIDO;
    
    IF(vDATAENTREGA > SYSDATE AND vVALORPEDIDO >= 9000) THEN
      vVALORPEDIDO := vVALORPEDIDO + vVALORPEDIDO * 0.0005;
    END IF;
    DBMS_OUTPUT.PUT_LINE(vVALORPEDIDO);
END;

select IDPEDIDO, VALORPEDIDO from pedido WHERE VALORPEDIDO > 9000 AND DATAPEDIDO > SYSDATE;