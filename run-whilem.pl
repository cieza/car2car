#!/usr/bin/perl

$nome_programa = $ARGV[0];
$numero_nos = $ARGV[1];
$experimento = $ARGV[2];
$rodadas = $ARGV[3];

$i = 1;
while($i <= $rodadas)
{
    system("mkdir -p /home/elise/car2car/resultados/".$nome_programa."/experimento_".$experimento."/rodada_".$i);
    $ark_saida = "/home/elise/car2car/resultados/".$nome_programa."/experimento_".$experimento."/rodada_".$i."/saida.txt";
    #$chamada_programa = "./waf --run=\"".$nome_programa." ".$numero_nos." ".$experimento." ".$i."\" > ".$ark_saida;
    #$seed = int(rand(10));
    $seed=$i;
    $chamada_programa = "NS_GLOBAL_VALUE=\"RngRun=".$seed."\" ./waf --run=\"".$nome_programa." ".$numero_nos." ".$experimento." ".$i."\" > ".$ark_saida;
    
    print($chamada_programa."\n");
    $tempo_antes = time();
    system($chamada_programa);
    #depois do system
    $tempo_depois = time();
    $tempo_demora = $tempo_depois - $tempo_antes;
    #print("Terminou rodada $i , o tempo foi de $tempo_demora segundos\n");
    
    print("Terminou rodada $i , o tempo foi de $tempo_demora segundos. saida abaixo: \n");
    system("echo $?");
    print("\n");
    
    $i = $i + 1;
}
