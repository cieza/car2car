#!/usr/bin/perl

$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-test-hp/experimento_1";

#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob/experimento_3";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_1";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_1";

#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-no-cache-no-mob-pollution/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob/experimento_2";
#$diretorio = "/home/elise/ndnSIM/ns-3/resultados/ndn-with-cache-no-mob-pollution/experimento_2";


# $arquivo_final= "/home/elise/ndnSIM/ns-3/resultados/arquivo-final-entrega";



#########################
opendir(diretorio, $diretorio);
@lista = readdir(diretorio);
closedir(diretorio);


#$sum_packets = 0;
$sum_packet_raw = 0;
#$sum_out_packets = 0;
$sum_satisfied_packet_raw = 0;
$count = 0;

foreach $dir_exp(@lista)
{

    if($dir_exp ne "." and $dir_exp ne "..")
    {
        $file_name1 = $diretorio."/".$dir_exp."/trace-app-delays.txt";
        $file_name2 = $diretorio."/".$dir_exp."/trace-rate.txt";

        $enviados = 0;
        $atendidos = 0;

        open ARK1, $file_name1;

        foreach(<ARK1>)
        {
            @linha = split(/\s+/);
            #print("linha: $linha[4] \n");
                    
            if($linha[4] eq "FullDelay")
            {
                #$enviados = $enviados + $linha[7];
                $atendidos = $atendidos + 1;
            }

        }

        if($linha[0] > 9)
        {
            $enviados = $enviados + $linha[7];
        }

        close ARK1;

        open ARK2, $file_name2;

        foreach(<ARK2>)
        {
            @linha = split(/\s+/);
            #print("linha: $linha[4] \n");

            if($linha[3] eq "dev=local(1)")
            {
            
                if($linha[4] eq "InInterests")
                {
                     #print("Entrou\n");
                     $enviados = $enviados + $linha[7];
                }
            }

        }

        close ARK2;

        $sum_packet_raw = $sum_packet_raw + $enviados;
        
        $sum_satisfied_packet_raw = $sum_satisfied_packet_raw + $atendidos;        

        $count = $count + 1;
        
    }
    
}

#medias
#$x =  $sum_packets/$count;
$media_enviados = $sum_packet_raw/$count;
#$a =  $sum_out_packets/$count;
$media_satisfeitos = $sum_satisfied_packet_raw/$count;

# razao entre interesses satisfeitos e interesses enviados
$taxa_entrega = $media_satisfeitos/$media_enviados;

# taxa_entrega: taxa de entrega calculada pela razão entre os interesses enviados e os interesses atendidos


print("Media_satisfeitos: $media_satisfeitos         Media_enviados: $media_enviados         Taxa_de_entrega: $taxa_entrega\n");


