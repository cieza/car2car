#!/usr/bin/perl

$diretorio = "/home/elise/car2car/resultados";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_1";

#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_2";


# $arquivo_final= "/home/elise/ndnSIM/ns-3/resultados/arquivo-final-entrega";

$n = $ARGV[0];

#########################
opendir(diretorio, $diretorio);
@lista = readdir(diretorio);
closedir(diretorio);


#$sum_packets = 0;
$sum_packet_raw = 0;
#$sum_out_packets = 0;
$sum_satisfied_packet_raw = 0;
$count = 0;
@scenarios = ();
$scenarios[0] = ["Politica","NaoProativo","ProAtivo"];
$k = 1;
foreach $dir_scenario(@lista)
{

    if($dir_scenario ne "." and $dir_scenario ne "..")
    {
        @experimentos_dirs = ();
        $dir_exp_n = $diretorio."/".$dir_scenario."/experimento_".$n;
        $dir_exp_n_1 = $diretorio."/".$dir_scenario."/experimento_".($n+1);
        $experimentos_dirs[0] = $dir_exp_n;
        $experimentos_dirs[1] = $dir_exp_n_1;
        
       
        
        $i = 1;
        @experimentos = ();
        foreach $experimento_dir(@experimentos_dirs)
        {
            
            opendir(diretorio_experimento, $experimento_dir);
            @lista_experimento = readdir(diretorio_experimento);
            closedir(diretorio_experimento);
        
            $sum_packet_raw = 0;
            $sum_satisfied_packet_raw = 0;
            $count = 0;
            $satisfeitos = 0;
            $interesses = 0;
            foreach $dir_exp(@lista_experimento)
            {
        
                if($dir_exp ne "." and $dir_exp ne "..")
                {
        
                    
                    $file_name = $experimento_dir."/".$dir_exp."/saida.txt";
                    #$packets = 0;
                    $ininterest_packet_raw = 0;
                    #$out_packets = 0;
                    $insatisfiedinterest_packet_raw = 0;
                    %taxas_entrega_satisfeitos = ();
                    %taxas_entrega_interesses = ();
                    open ARK, $file_name;
                    foreach(<ARK>)
                    {
                        @linha = split(/\s+/);
                        
            
              
                        if($linha[0] eq "Taxa_Entrega_Absoluta")
                        {
                            $taxas_entrega_satisfeitos{$linha[2]} = $linha[4];
                            $taxas_entrega_interesses{$linha[2]} = $linha[6];
                            
                        }

                    }
                    close ARK;
                    @valores = values %taxas_entrega_satisfeitos;
                    
                    foreach(@valores)
                    {
                        $satisfeitos = $satisfeitos + $_;
                    }
                    
                    @valores = values %taxas_entrega_interesses;
                    
                    foreach(@valores)
                    {
                        $interesses = $interesses + $_;
                    }


        
                    $count = $count + 1;
                }

        
            }
            
            $taxa_entrega = $satisfeitos/$interesses;
            $experimentos[$i] = $taxa_entrega;
            $i = $i + 1;
        
        }
        
        $experimentos[0] = $dir_scenario;
        $scenarios[$k] = [@experimentos];
        $k = $k + 1;
    }
    
    
}


$file_name = "/home/elise/car2car/txentrega.txt";
open ARK, ">".$file_name;
select ARK;
$i = 0;
while($i < 3)
{
    $j = 0;
    while($j < $k)
    {
        @experimentos = @scenarios[$i];
        print("$scenarios[$j][$i]      \t");
        $j = $j + 1;
    }
    print("\n");
    $i = $i + 1;
}


close ARK;
#medias
#$x =  $sum_packets/$count;

