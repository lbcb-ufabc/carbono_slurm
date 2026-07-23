#!/bin/bash

## nodes = quantidade de nodes
#SBATCH --nodes=1
##
#SBATCH --partition=nanotubo
#
## ntasks-per-node = quantidade de processos por node
#SBATCH --ntasks-per-node=16
##
## time = quantidade de tempo
#SBATCH --time=5-00:00:00
##
## Nome do job . Aparece na saida do comando 'qstat' .
## E recomendado, mas nao necesssario, que o nome do job
## seja o mesmo que o nome do arquivo de input
#SBATCH --job-name=protein_x
##
## Consulte <https://slurm.schedmd.com/sbatch.html> para mais informacoes sobre
## as diretivas acima.

echo -e "\n## Job iniciado em $(date +'%d-%m-%Y as %T') #####################\n"

## Variavel com o diretorio de scratch do job
## Consulte <https://slurm.schedmd.com/sbatch.html#lbAH> para mais informacoes
## sobre as variaveis de ambiente do SLURM.
##SCRATCH=/home/ana.scott/yolanda/complexo_fap_dim_a_48/scratch/local
WRKDIR=$SLURM_SUBMIT_DIR

## O nome dos arquivos de input e output sao baseados no
## nome do job (linha "#SBATCH --jobname=xxx" acima).
## Observe que nao e obrigatorio esta forma de nomear os arquivos.
INP="production-charmm_namd_gpu_dim.inp"
OUT="production-charmm_namd_gpu_dim.out"

## O diretorio onde o job sera executado sera apagado, por padrao, ao
## final do mesmo.
## Se desejar que nao seja apagado, substitua Y por N.
##APAGA_SCRATCH=Y

## Informacoes do job impressos no arquivo de saida.
echo -e "\n## Jobs ativos de $USER: \n"
squeue -a --user=$USER
echo -e "\n## Node de execucao do job:         $(hostname -s) \n"
echo -e "\n## Numero de tarefas para este job: $SLURM_NTASKS \n"

##-------  Inicio do trabalho     ----- #
#########################################

## Configura o ambiente de execucao do software.
#module load gnu12/12.2.0
#module load intel/2021.2.0
#module load intel/2023.1.0
module swap openmpi4 impi/2021.9.0
module swap gnu12 intel/2023.1.0
module load charmm/48b2
module load openmpi4/4.1.4

## Informacoes sobre o ambiente de execucao impressos no arquivo de saida.
echo -e "\n## Diretorio de submissao do job:   $SLURM_SUBMIT_DIR \n"
echo -e "\n## Diretorio de scratch do job:     $WRKDIR \n"
echo -e "\n## Arquivo de input:                $INP \n"

## Cria o diretorio de scratch para o job.
##mkdir -p $WRKDIR

## Transfere os inputs e arquivos necessarios para o diretorio de scratch
##cd $SLURM_SUBMIT_DIR
##cp -r *  $WRKDIR/
##cd $WRKDIR

## Execucao do software

EXEC=/opt/ohpc/pub/apps/charmm/48b2/bin/charmm

for i in {7..30}; do

    mpirun -np 32 $EXEC -i vmod$i.inp -o vmod$i.out 
    
done 
## Copia o diretorio de scratch para o diretorio original do job.
##cp -r $WRKDIR/ $SLURM_SUBMIT_DIR/

## Apaga o diretorio de scratch do job.
if [ x"$APAGA_SCRATCH" = x"Y" ]; then
        rm -rf $WRKDIR
else
    echo -e "\nO diretorio \e[00;31m$WRKDIR\e[00m deve ser removido manualmente"
    echo -e "para evitar problemas para outros jobs e/ou usuarios. \n"
fi

echo -e "\n## Job finalizado em $(date +'%d-%m-%Y as %T') ###################"
