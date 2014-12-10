#!/usr/bin/perl

$nome_programa = $ARGV[0];
$numero_nos = $ARGV[1];
$experimento = $ARGV[2];
$rodada = $ARGV[3];

system("mkdir -p ~/ndnSIM/ns-3/resultados/".$nome_programa."/experimento_".$experimento."/rodada_".$rodada);

$chamada_programa = "./waf --run=\"".$nome_programa." ".$numero_nos." ".$experimento." ".$rodada."\"";

print($chamada_programa."\n");

system($chamada_programa);
