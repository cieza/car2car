#!/usr/bin/perl

$nome_programa = $ARGV[0];
$numero_nos = $ARGV[1];
$experimento = $ARGV[2];
$rodadas = $ARGV[3];

$i = 1;
while($i <= $rodadas)
{
  system("mkdir -p ~/ndnSIM-nom-rapid-car2car/resultados/".$nome_programa."/experimento_".$experimento."/rodada_".$i);

  $chamada_programa = "./waf --run=\"".$nome_programa." ".$numero_nos." ".$experimento." ".$i."\"";

  print($chamada_programa."\n");
  system($chamada_programa);
  
  $i = $i + 1;
}
