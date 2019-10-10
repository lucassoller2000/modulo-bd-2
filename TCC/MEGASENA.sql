--------------------------------------------------------
--  Arquivo criado - Domingo-Junho-17-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package PCK_MEGASENA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "MEGASENA"."PCK_MEGASENA" is

  -- Author  : ANDRENUNES
  -- Purpose : Manipulação na base de dados da Loteria mais conhecida do Brasil
  
  -- Variáveis Globais - definidas em procedimento específico
  gPremio_sena          number(12,2) := 0;
  gPremio_quina         number(12,2) := 0;
  gPremio_quadra        number(12,2) := 0;
  gAcumulado_proximo_05 number(12,2) := 0;
  gAcumulado_final_ano  number(12,2) := 0;
  
  -- Public type declarations
  procedure salvaConcurso (pConcurso in integer,
                           pData     in date,
                           pPremio   in number);
  function buscaPercentual(pIdentificador in varchar2) return number;
  procedure atualizaAcertadores (pConcurso in integer);
  function buscaMaiorIdConcurso return integer;
  function buscaMaiorIdApostaPremiada return integer;
  procedure geraProximoConcurso;
  
end pck_megasena;

/
