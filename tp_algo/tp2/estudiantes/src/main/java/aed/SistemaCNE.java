package aed;
public class SistemaCNE<T> {
    private String[] nombres_Partidos;
    private String[] nombres_Distritos;
    private int[] bancasPorDistritos;
    private int[] votosPresidenciales;
    private int[][] rangoMesasDistritos;
    private int[][] votosDiputados;
    private Heap<T>[] votosDiputadosHeap; // Es un array de heaps que permite calcular las bancas por distrito.
    private int[] max_Votos_Presi; // Los votos de los dos partidos mas votados.
    private int votosTotalesPresi; // Votos totales presidenciales.
    private int[] votosDipXDistrito; // Votos totales de diputados por distrito.
    private boolean[] distritosEscrutados; // Se ve si un distrito ya pasó la función de resultadosDiputados
    private int[][] escrutinioProvisorio; // Se guardan la cantidad de bancas otorgadas a cada partido por cada distrito.
    private int[][] divisores; // Se guarda el ultimo número por el que se dividió al partido para obtener el cociente para la matríz de Dhondt.
    

    public class VotosPartido{
        private int presidente;
        private int diputados;
        VotosPartido(int presidente, int diputados){this.presidente = presidente; this.diputados = diputados;}
        public int votosPresidente(){return presidente;}
        public int votosDiputados(){return diputados;}
    }
    /*
    
    INV REP: 

     * nombres_Partidos todos sus elementos son distintos, la ultima posicion es para los votos en blancos(partido "Blancos").
     
     * nombres_Distritos todos sus elementos son distintos.
     
     * votosPresidenciales tiene longitud nombres_Partidos, todos sus elementos son >= 0 y la suma de todos sus elementos es igual a votosTotalPresi.
      
     * votosTotalPresi es >= 0.
     
     * max_Votos_Presi tiene longitud 2 y todos sus elementos son positivos y el primer elemento es >= al segundo elemento. 

     * votosDiputados es una matriz de nombres_Distritos por nombres_Partidos.
     
     * votosDiputadosHeap todos los elementos cumplen que son null o si no es null es un heap que cumple que su cantidad de elementos es igual a longitud de nombres_Partidos - 1
       y dentro de cada elemento todos sus valores son positivos, todos los heaps cumplen que todos sus elementos en la posicion 0
       son >= a 0 y <= a nombres_Partidos.length - 1, y la posicion 1 son postivos. 

     * votosDipXDistrito tiene longitud nombres_Distritos, todos sus elementos son positivos y para todo indice valido i, votosDipXDistrito[i] = a la suma de votosDiputados[i].

     * bancasPorDistrtios tiene longitud nombres_Distritos sus elementos son positivos.

     * rangoDeMesasDistrito tiene longitud nombres_Distritos, todos sus elementos tienen longitud 2 y a su vez cada elemento es postivios, rangoMesasDistrito[0][0] es igual a 0,
       para todo indice valido i, rangoDeMesasDistrito[i][0] <= rangoDeMesasDistrito[i][1] y rangoDeMesasDistrito[i][1] = rangoDeMesasDistrito[i+1][0]+1 .
     
     * distritosEscrutados tiene largo nombres_Distrito y sus elementos pueden ser solo True o False.
     
     * escrutinioProvisorio tiene longitud nombres_Distritos y cada elemento tiene longitud 0 o largo de nombres_Partidos - 1. 
     
     * divisores tiene longitud nombres_Distritos y cada elemento tiene longitud 0 o largo de nombres_Partidos - 1.
     
     */

    public SistemaCNE(String[] nombresDistritos, int[] diputadosPorDistrito, String[] nombresPartidos, int[] ultimasMesasDistritos) {  //O(P * D)
        nombres_Partidos=nombresPartidos;  // O(1)
        votosPresidenciales = new int[nombresPartidos.length];  // O(P)
        rangoMesasDistritos = new int[nombresDistritos.length][2];  //O(D)
        votosDiputados = new int[nombresDistritos.length][nombresPartidos.length];  //O(P*D)
        votosDiputadosHeap = new Heap[nombresDistritos.length];  // O(D)
        distritosEscrutados = new boolean[nombresDistritos.length];  // O(D)
        escrutinioProvisorio = new int[nombresDistritos.length][0];  // O(P*D)
        nombres_Distritos = nombresDistritos;  // O(1)
        bancasPorDistritos = diputadosPorDistrito;  // O(1)
        max_Votos_Presi = new int[2];  // O(1)
        votosTotalesPresi = 0;  // O(1)
        votosDipXDistrito = new int[nombresDistritos.length]; // O(D)
        divisores = new int[nombresDistritos.length][0]; // O(D)       
        for (int idDistrito = 0; idDistrito < nombresDistritos.length; idDistrito++) {  // O(D) 

            if (idDistrito == 0) {  // O(1)
                rangoMesasDistritos[idDistrito][0] = 0;  // O(1)
             } else {
                rangoMesasDistritos[idDistrito][0] = rangoMesasDistritos[idDistrito - 1][1] + 1;  // O(1)
             }
            rangoMesasDistritos[idDistrito][1] = ultimasMesasDistritos[idDistrito]-1;  // O(1)            
           
            
        }

    }
    

    public String nombrePartido(int idPartido) { // O(1)
        return nombres_Partidos[idPartido]; // O(1)
    }

    public String nombreDistrito(int idDistrito) { // O(1)
        return nombres_Distritos[idDistrito]; // O(1)
    }

    public int diputadosEnDisputa(int idDistrito) { // O(1)
        return bancasPorDistritos[idDistrito]; // O(1)
    }

    public static int BinarySearchV2(int idMesa,int[][] rangoMesasDistritos ){ // O(log(P))
        int left=0; // O(1)
        int right= rangoMesasDistritos.length-1; // O(1)
        int distrito=0; // O(1)
        while (left<=right){ // En peor caso itera O(log(n)) n = longitud del array
            int mid = (right + left)/2; // O(1)
            if (rangoMesasDistritos[mid][0]<=idMesa && rangoMesasDistritos[mid][1]>=idMesa){ // O(1)
                distrito=mid; // O(1)
            }
            if (rangoMesasDistritos[mid][0]>idMesa){ // O(1)
                right=mid-1; // O(1)
            }else{
                left=mid+1; // O(1)
            }

        }
        return distrito; // O(1)
    }

    public String distritoDeMesa(int idMesa) {// O(1)
        return nombres_Distritos[BinarySearchV2(idMesa,rangoMesasDistritos)]; // O(1)
    }

    public void registrarMesa(int idMesa, VotosPartido[] actaMesa) { // O(P + log(D))
        int distrito=BinarySearchV2(idMesa,rangoMesasDistritos); // O(log(D))
        if (votosDiputados[distrito].length == 0){ // O(1)
            votosDiputados[distrito] = new int[nombres_Partidos.length];// O(P)
        }
        escrutinioProvisorio[distrito] = new int[nombres_Partidos.length -1]; // O(P)
        divisores[distrito] = new int[nombres_Partidos.length-1]; //O(P)
        votosTotalesPresi = 0; // O(1)
        votosDipXDistrito[distrito] = 0; // O(1)
        int[][] toHeapDistrito = new int[nombres_Partidos.length-1][2]; //  O(2*P)
        for(int idPartido=0;idPartido<nombres_Partidos.length;idPartido++){ // O(P)
            votosPresidenciales[idPartido]+=actaMesa[idPartido].presidente; // O(1)
            votosTotalesPresi+=votosPresidenciales[idPartido]; // O(1)
            votosDiputados[distrito][idPartido]+=actaMesa[idPartido].diputados; // O(1)
            votosDipXDistrito[distrito]+=votosDiputados[distrito][idPartido]; // O(1)
            if (idPartido < nombres_Partidos.length-1){ // O(1)
                toHeapDistrito[idPartido][1] = votosDiputados[distrito][idPartido]; // O(1)
                toHeapDistrito[idPartido][0] = idPartido; // O(1)
            }
        }
        votosDiputadosHeap[distrito] = new Heap(toHeapDistrito); // O(P)
        for(int idPartido=0;idPartido<nombres_Partidos.length;idPartido++){ // O(P)
            if (votosPresidenciales[idPartido] > max_Votos_Presi[0]){ // O(1)
                max_Votos_Presi[0] = votosPresidenciales[idPartido]; // O(1)
            }           
        }
        for (int idPartido = 0; idPartido < nombres_Partidos.length ; idPartido++) { // O(P)
            if (votosPresidenciales[idPartido] < max_Votos_Presi[0] && max_Votos_Presi[1] < votosPresidenciales[idPartido]) { // O(1)
                max_Votos_Presi[1] = votosPresidenciales[idPartido]; // O(1)
            }       
        }
        distritosEscrutados[distrito] = false; // O(1)

    }        

    public int votosPresidenciales(int idPartido) { // O(1)
        return votosPresidenciales[idPartido]; // O(1)
    }

    public int votosDiputados(int idPartido, int idDistrito) { // O(1)
        return votosDiputados[idDistrito][idPartido]; // O(1)
    }

    public int[] resultadosDiputados(int idDistrito){ // O(D_d * log(P))
        int bancasTotal = diputadosEnDisputa(idDistrito); // O(1)
        // Mira si ya no habia pasado por la función.
        if (!distritosEscrutados[idDistrito]) { // O(1)
            int bActual=1; // O(1)
            while (bActual <= bancasTotal) { // O(D_d * P) El while itera por bancasTotal y en el peor caso se ejecuta la función modificar que es O(log(P)) por cada iteración
                int idPartido = votosDiputadosHeap[idDistrito].getMaxId(); // O(1)            
                divisores[idDistrito][idPartido]+=1; // O(1)
                float votosDePartidoEnDistrito = (float) votosDiputados[idDistrito][idPartido]; // O(1)               
                if ( (votosDePartidoEnDistrito/ votosDipXDistrito[idDistrito])*100 >=3){ // O(1)
                    votosDiputadosHeap[idDistrito].modificar(votosDiputados[idDistrito][idPartido], divisores[idDistrito][idPartido]+1); // O(log(P))
                    escrutinioProvisorio[idDistrito][idPartido]+=1; // O(1)
                    bActual++; // O(1)
                }
                else{
                    votosDiputadosHeap[idDistrito].modificar(votosDiputados[idDistrito][idPartido], divisores[idDistrito][idPartido]+1); // O(log(P))
                }
            }            
        } 
        distritosEscrutados[idDistrito]=true; // O(1)
        return escrutinioProvisorio[idDistrito]; // O(1)
    }

    // Como ya tenemos los votos totales presidenciales y los dos partidos con mas votos, solo vemos si hay alguno que gano con mas del 45% o que haya llegado al 40% pero con mas de 10 puntos de diferencia con el segundo.
    public boolean hayBallotage(){ // O(1)
        return (((max_Votos_Presi[0] * 100 / votosTotalesPresi) < 45) &&
        (((max_Votos_Presi[0] * 100 / votosTotalesPresi) - (max_Votos_Presi[1] * 100.0 / votosTotalesPresi)) < 10)) ||
        (max_Votos_Presi[0] * 100 / votosTotalesPresi) < 40; // Son todas instrucciones O(1)
    }
}
//fin
