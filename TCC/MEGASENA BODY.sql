--------------------------------------------------------
--  Arquivo criado - Domingo-Junho-17-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PCK_MEGASENA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "MEGASENA"."PCK_MEGASENA" is

  /* Busca valores percentuais conforme regra definida na tabela 'Regra_Rateio_Premio' */
  function buscaPercentual(pIdentificador in varchar2) return number as
        -- 
        v_percentual  regra_rateio_premio.percentual%type; -- herdará as propriedades do campo percentual
      begin
        
        -- busca percentual conforme parametro de entrada
        select percentual
        into   v_percentual   -- atribuí valor para a variavel
        from   regra_rateio_premio
        where  identificador = lower(pIdentificador);
        
        return v_percentual;
      exception
        when no_data_found then
          dbms_output.put_line('Erro: '||pIdentificador);
          raise_application_error(-20002, sqlerrm);
      end buscaPercentual;
  ---------------------------------------------------------------------------------------------------------------------------------------
  /* Executa o rateio dos premios conforme definção das regras */
  procedure defineRateioPremio (pPremio in number) as
    begin
    
       gPremio_sena          := buscaPercentual('premio_sena') * pPremio;
       gPremio_quina         := buscaPercentual('premio_quina') * pPremio;
       gPremio_quadra        := buscaPercentual('premio_quadra') * pPremio;
       gAcumulado_proximo_05 := buscaPercentual('acumulado_05') * pPremio;
       gAcumulado_final_ano  := buscaPercentual('acumulado_final_ano') * pPremio;
  
    end defineRateioPremio;

  ---------------------------------------------------------------------------------------------------------------------------------------
  /* Salva o registro referente ao concurso */
  procedure salvaConcurso (pConcurso in integer,
                           pData     in date,
                           pPremio   in number) as
    begin

       defineRateioPremio(pPremio);
       
       --insereConcurso( pConcurso, pData, gPremio_Sena, gPremio_Quina, gPremio_Quadra, gAcumulado_proximo_05, gAcumulado_final_ano );
       
       Insert into Concurso 
           (Idconcurso, Data_Sorteio, Premio_Sena, Premio_Quina, Premio_Quadra, Acumulado_Proximo_05, Acumulado_Final_Ano)
       Values 
           (pConcurso, pData, gPremio_Sena, gPremio_Quina, gPremio_Quadra, gAcumulado_proximo_05, gAcumulado_final_ano);
    end salvaConcurso;
  ---------------------------------------------------------------------------------------------------------------------------------------
    /*
     Questão "A" - implementar rotina que irá inserir um novo concurso
    */
  procedure geraProximoConcurso as
   v_ultimo_id CONCURSO.IDCONCURSO%TYPE;
   v_ultimo_id_aposta_premiada APOSTA_PREMIADA.IDAPOSTA_PREMIADA%TYPE;
   v_valor_proximo_premio CONCURSO.PREMIO_SENA%TYPE;
   v_acumulou CONCURSO.ACUMULOU%TYPE;
   v_premio_sena CONCURSO.PREMIO_SENA%TYPE;
  
   begin
      v_ultimo_id := buscaMaiorIdConcurso;
      
      if( v_ultimo_id > 0) then
      v_ultimo_id := v_ultimo_id;
      else
       v_ultimo_id := 0;
      end if;
      
      select sum(valor)
      into v_valor_proximo_premio
      from aposta
      where idconcurso = v_ultimo_id;
      
      v_valor_proximo_premio := v_valor_proximo_premio * 0.453; 
      
      select acumulou
      into v_acumulou
      from concurso
      where idconcurso = v_ultimo_id;
      
      if(v_acumulou = 1) then
      
          select premio_sena
          into v_premio_sena
          from concurso
          where idconcurso = v_ultimo_id;
          
          v_valor_proximo_premio := v_valor_proximo_premio + v_premio_sena;
      
      end if;
      
      salvaConcurso((v_ultimo_id+1), sysdate, v_valor_proximo_premio);
      
   end geraProximoConcurso;
  ---------------------------------------------------------------------------------------------------------------------------------------
    /*
     Questão "B" - implementar rotina que irá inserir todos os acertadores de um determinado concurso
    */
  procedure atualizaAcertadores (pConcurso in integer) as 
   v_premio_quadra CONCURSO.PREMIO_QUADRA%TYPE;
   v_premio_quina CONCURSO.PREMIO_QUINA%TYPE;
   v_premio_sena CONCURSO.PREMIO_SENA%TYPE;
   v_primeira_dezena CONCURSO.PRIMEIRA_DEZENA%TYPE;
   v_segunda_dezena CONCURSO.SEGUNDA_DEZENA%TYPE;
   v_terceira_dezena CONCURSO.TERCEIRA_DEZENA%TYPE;
   v_quarta_dezena CONCURSO.QUARTA_DEZENA%TYPE;
   v_quinta_dezena CONCURSO.QUINTA_DEZENA%TYPE;
   v_sexta_dezena CONCURSO.SEXTA_DEZENA%TYPE;
   v_pessoas_que_ganharam_quadra integer := 0;
   v_pessoas_que_ganharam_quina integer := 0;
   v_pessoas_que_ganharam_sena integer := 0;
   v_acertos integer;
   v_ultimo_id APOSTA_PREMIADA.IDAPOSTA_PREMIADA%TYPE;
  
   CURSOR c_lista_id_apostas is
      select idaposta 
      from aposta
      where idconcurso = pConcurso;
      
   CURSOR c_lista_numeros_do_jogador(pIdAposta in integer) is
      select numero
      from numero_aposta
      where idaposta = pIdAposta;
      
   begin
   
      v_ultimo_id := buscaMaiorIdApostaPremiada;
      
      if( v_ultimo_id > 0) then
      v_ultimo_id := v_ultimo_id;
      
      else
       v_ultimo_id := 0;
      end if;
      
      select primeira_dezena, segunda_dezena, terceira_dezena, quarta_dezena, quinta_dezena, sexta_dezena
      into v_primeira_dezena, v_segunda_dezena, v_terceira_dezena, v_quarta_dezena, v_quinta_dezena, v_sexta_dezena
      from concurso
      where idconcurso = pConcurso;
      
      select premio_quadra, premio_quina, premio_sena
      into v_premio_quadra, v_premio_quina, v_premio_sena
      from concurso
      where idconcurso = pConcurso;
      
      for reg in c_lista_id_apostas loop
         v_acertos := 0;
         for reg2 in c_lista_numeros_do_jogador(reg.idaposta) loop
         
         if(v_primeira_dezena = reg2.numero) then
         v_acertos := v_acertos + 1;
         
         elsif(v_segunda_dezena = reg2.numero) then
         v_acertos := v_acertos + 1;
         
         elsif(v_terceira_dezena = reg2.numero) then
         v_acertos := v_acertos + 1;
         
         elsif(v_quarta_dezena = reg2.numero) then
         v_acertos := v_acertos + 1;
         
         elsif(v_quinta_dezena = reg2.numero) then
         v_acertos := v_acertos + 1;
         
         elsif(v_sexta_dezena = reg2.numero) then
         v_acertos := v_acertos + 1;
         end if;
         
         end loop;
         
         if(v_acertos = 4) then
         v_ultimo_id := v_ultimo_id + 1;
         v_pessoas_que_ganharam_quadra := v_pessoas_que_ganharam_quadra +1;
         insert into aposta_premiada (idaposta_premiada, idaposta, acertos, valor) values
         (v_ultimo_id, reg.idaposta, 4, v_premio_quadra);
         
         elsif(v_acertos = 5) then
         v_ultimo_id := v_ultimo_id + 1;
         v_pessoas_que_ganharam_quina := v_pessoas_que_ganharam_quina +1;
         insert into aposta_premiada (idaposta_premiada, idaposta, acertos, valor) values
         (v_ultimo_id, reg.idaposta, 5, v_premio_quina);
         
         elsif(v_acertos = 6) then
         v_ultimo_id := v_ultimo_id + 1;
         v_pessoas_que_ganharam_sena := v_pessoas_que_ganharam_sena +1;
         insert into aposta_premiada (idaposta_premiada, idaposta, acertos, valor) values
         (v_ultimo_id, reg.idaposta, 6, v_premio_sena);
         end if;
         
      end loop;
      if(v_pessoas_que_ganharam_sena = 0) then
          update concurso 
          set acumulou = 1 
          where idconcurso = pConcurso;
      end if;
      
      update aposta_premiada
      set valor = valor / v_pessoas_que_ganharam_quadra
      where acertos = 4
      and idaposta in
      (select idaposta from aposta where idconcurso = pConcurso);
      
      update aposta_premiada
      set valor = valor / v_pessoas_que_ganharam_quina
      where acertos = 5
      and idaposta in
      (select idaposta from aposta where idconcurso = pConcurso);
      
      update aposta_premiada
      set valor = valor / v_pessoas_que_ganharam_sena
      where acertos = 6
      and idaposta in
      (select idaposta from aposta where idconcurso = pConcurso);
    
      geraProximoConcurso;
      
   end atualizaAcertadores;
   ---------------------------------------------------------------------------------------------------------------------------------------

  function buscaMaiorIdConcurso return integer as
   v_ultimoId concurso.idconcurso%type;
   begin
     select MAX(idconcurso)
     into v_ultimoId
     from concurso;
     return v_ultimoId;
   end buscaMaiorIdConcurso;
   
   ---------------------------------------------------------------------------------------------------------------------------------------
   
   function buscaMaiorIdApostaPremiada return integer as
   v_ultimoId aposta_premiada.idaposta_premiada%type;
   begin
     select MAX(idaposta_premiada)
     into v_ultimoId
     from aposta_premiada;
     return v_ultimoId;
   end buscaMaiorIdApostaPremiada;
begin
  -- Initialization
  null; --<Statement>;
end pck_megasena;

/
