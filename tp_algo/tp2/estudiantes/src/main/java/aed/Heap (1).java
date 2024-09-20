package  aed;

/*
INV: 

* Para todo i natural que sea indice valido de elems , si 2*k+1 y 2*k+2 es indice valido de elems
entonces elems[i][1] es mayor o igual a elems[2*k+1][1] y elems[2*k+2].
* cantElems cumple que es mayor a o igual a 0 y menor estricto a elems.length

*/

public class Heap<T> {
    private int[][] elems;
    private int cantElems;

    public Heap(int size){ //O(1)
        elems = new int[size][2]; //O(1)
        cantElems = 0; //O(1)

    }
    public Heap(int[][] toHeap){ // Algoritmo de Floyd O(n), n = toHeap.length
        int tamaño = toHeap.length; 
        this.elems = toHeap;
        int father = toHeap.length/2 - 1;
            while  (father >= 0){
                int sonLeft = 2*father+1;
                int sonRight = 2*father+2;
                int posCorrect = father;                
                while ((sonLeft < toHeap.length && toHeap[sonLeft][1] > toHeap[posCorrect][1]) ||
                (sonRight < toHeap.length && toHeap[sonRight][1] > toHeap[posCorrect][1])){
                    if (sonLeft < toHeap.length && sonRight < toHeap.length){
                        if (toHeap[sonLeft][1]> toHeap[sonRight][1]){
                            swap(sonLeft, posCorrect);
                            posCorrect = sonLeft;
                        }
                        else{
                            swap(sonRight, posCorrect);
                            posCorrect = sonRight;                           
                        }
                    }
                    else{
                        swap(sonLeft, posCorrect);
                        posCorrect = sonLeft;
                    }
                    sonLeft = 2*posCorrect+1;
                    sonRight = 2*posCorrect+2;

                }
                father = father -1;          
            }
        cantElems = tamaño;
    }

    public int getMaxId() { //O(1)
        return elems[0][0]; //O(1)
    }

    // Requiero que cuando ingrese un elemento, ese sea igual a todos los anteriores.
    public void insertionEquals(int idPartido, int value){  //O(1)
        if(cantElems == 0){ //O(1)
            elems[0][0] = idPartido; //O(1)
            elems[0][1] = value; //O(1)
        }
        else {
            elems[cantElems][0] = idPartido; //O(1)
            elems[cantElems][1] = value; //O(1)
        }
        cantElems++; //O(1)

    }
    public void insertion(int value,int idPartido){ //O(log(|elems|))
       
        if (cantElems == 0){ //O(1)
            elems[0][0] = idPartido; //O(1)
            elems[0][1] = value; //O(1)
        }
        else{
            elems[0][0] = idPartido; //O(1)
            elems[cantElems-1][1] = value; //O(1)
            int indexRight = cantElems -1; //O(1)
            int indexParent = indexRight-1/2; //O(1)
            while ((indexParent >= 0) && elems[indexRight][1] > elems[indexParent][1]){ //O(|elems|)
                swap(indexRight,indexParent); //O(1)
                indexRight = indexParent; //O(1)
            }     
        }
        cantElems++; // O(1)
    }

    // Baja al elemento en la posicion index a su lugar correcto dentro del Heap.
    public void down(int index){ // O(log|elems|)
        int sonLeft = 2*index +1; // O(1)
        int sonRight = 2*index + 2; // O(1)
        while ((sonLeft < elems.length && elems[sonLeft][1] > elems[index][1]) ||
            (sonRight < elems.length && elems[sonRight][1] > elems[index][1])){ // O(log(|elems|))
            if (sonLeft < elems.length && sonRight < elems.length){ // O(1) 
                if (elems[sonLeft][1]> elems[sonRight][1]){ // O(1)
                    swap(sonLeft, index); // O(1)
                    index = sonLeft; // O(1)
                }
                else{
                    swap(sonRight, index); // O(1)
                    index = sonRight; // O(1)                        
                    }
            }
            else{
                swap(sonLeft, index); // O(1)
                index = sonLeft; // O(1)
                }
                sonLeft = 2*index+1; // O(1)
                sonRight = 2*index+2; // O(1)
        }    
    }

    // Modifica el valor del primer elemento del heap y luego lo baja a su posicion correcta.
    public void modificar(int votos, int divisor) { // O(log(|elems|))
        int cociente = votos/divisor; // O(1)
        elems[0][1] = cociente; // O(1)
        down(0); // O(log(|elems|))
    }

    private void swap(int pos1, int pos2){ // O(1)
        //cambio pos1 por pos2
        int[] temp = elems[pos1]; // O(1)
        elems[pos1] = elems[pos2]; // O(1)
        elems[pos2] = temp; // O(1)
    }
}
