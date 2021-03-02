public class Grid {
  Node[][] node;

  public Grid() {
    node = new Node[nR][nC];

    for (int i = 0; i < nR; i++) {
      for (int j = 0; j < nC; j++)
        node[i][j] = new Node(i, j);
    }
  }

  public void display() {
    noStroke();
    rectMode(CORNERS);

    for (int i = 0; i < nR; i++) {
      for (int j = 0; j < nC; j++) {
        if (node[i][j].n > 0)
          fill(50+(node[i][j].n), 50+(node[i][j].n%2)*10, 20);
        else if (node[i][j].n == -1) //E' una mela
          fill(0, 150, 0);
        else //Non c'è nulla
        fill(0);

        rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);

        if ((i == iHead) && (j == jHead)) { //testa dello Snake
          Direction dir = direction();
          fill(50+(node[i][j].n), 50, 20+(node[i][j].n)/2);
          rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);
          stroke(0);
          strokeWeight(3);
          if ((dir.dI == 1) && (dir.dJ == 0)) { //Spostamento in basso...
            point(j*dX+dX/1.5, i*dY+dY*0.75);
            point(j*dX+dX/2.5, i*dY+dY*0.75);
          }
          if ((dir.dI == -1) && (dir.dJ == 0)) { //Spostamento in alto...
            point(j*dX+dX/1.5, i*dY+dY/4);
            point(j*dX+dX/2.5, i*dY+dY/4);
          }
          if ((dir.dI == 0) && (dir.dJ == 1)) { //Spostamento verso destra...
            point(j*dX+dX*0.75, i*dY+dY/1.5);
            point(j*dX+dX*0.75, i*dY+dY/2.5);
          }
          if ((dir.dI == 0) && (dir.dJ == -1)) { //Spostamento verso sinistra...
            point(j*dX+dX/4, i*dY+dY/1.5);
            point(j*dX+dX/4, i*dY+dY/2.5);
          }
          noStroke();
        }
      }
    }
  }

  public Grid workingGrid() { //Crea una sorta di copia della grid corrente, su cui poter scrivere a piacimento, senza intaccare i valori della grid originale
    Grid res = new Grid();
    for (int i = 0; i < nR; i++) {
      for (int j = 0; j < nC; j++) {
        if (node[i][j].n > 0)
          res.node[i][j].open = false; 
        else {
          res.node[i][j].open = true;
          res.node[i][j].n = nR*nC;
        }
      }
    }
    return res;
  }

  public void debug1() {
    noStroke();
    rectMode(CORNERS);
    textSize(dY*0.5);
    textAlign(CENTER, CENTER);

    for (int i = 0; i < nR; i++) {
      for (int j = 0; j < nC; j++) {
        if (node[i][j].n > 0) { //corpo dello Snake
          fill(50, 50, 50);
          rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);
          if ((i == iHead) && (j == jHead)) { //testa dello Snake
            fill(120, 120, 0);
            rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);
          }
          fill(255, 0, 0);
          text("" + node[i][j].n, (2*j+1)*dX/2, (2*i+1)*dY/2);
        } else if (node[i][j].n == -1) { //E' una mela
          fill(0, 150, 0);
          rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);
          fill(0, 0, 0);
          text("" + node[i][j].n, (2*j+1)*dX/2, (2*i+1)*dY/2);
        } else { //Non c'è nulla
          fill(180);
          rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);
          fill(0, 90, 0);
          text("" + node[i][j].n, (2*j+1)*dX/2, (2*i+1)*dY/2);
        }
      }
    }
  }

  public void debug2() {
    noStroke();
    rectMode(CORNERS);
    textSize(dY*0.5);
    textAlign(CENTER, CENTER);

    Grid wg = workingGrid();
    wg.setValues(iTarget, jTarget, 0);

    for (int i = 0; i < nR; i++) {
      for (int j = 0; j < nC; j++) {

        fill(240);
        rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1); //Disegna ogni casella
        fill(0, 0, 100);
        text("" + wg.node[i][j].n, (2*j+1)*dX/2, (2*i+1)*dY/2);

        if ((wg.node[i][j].n == 0) && (wg.node[i][j].open)) { //mela
          fill(150, 0, 150);
          rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1); //Disegna ogni casella
          fill(255);
          text("" + wg.node[i][j].n, (2*j+1)*dX/2, (2*i+1)*dY/2);
        } else if (!wg.node[i][j].open) { //corpo dello Snake
          fill(0);
          rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);
          if ((i == iHead) && (j == jHead)) { //testa dello Snake
            fill(120, 120, 0);
            rect(j*dX, i*dY, (j+1)*dX-1, (i+1)*dY-1);
            fill(0, 190, 0);
            text("" + head, (2*j+1)*dX/2, (2*i+1)*dY/2);
          }
        }
      }
    }
  }

  //Metodo da richiamare su workingGrid() che mi dice se due nodi sono connessi
  //Attenzione: la prima chiamata del metodo può essere fatta su un nodo n1 che può essere sia chiuso sia aperto,
  //mentre il nodo n2 deve essere aperto.
  //Il metodo restituisce true se tra i due due nodi c'è connessione, altrimenti restituisce false
  //Sostanzialmente scorre il nodo n1 (lasciando fisso n2) in cerca di connessione per la griglia, se c'è connessione n1 == n2 => return true
  public boolean connection(Node n1, Node n2) {
    boolean res = false;
    int i = n1.i;
    int j = n1.j;
    node[i][j].open = false;

    if ((i == n2.i) && (j == n2.j))
      res = true;
    else {
      if ((i > 0) && (node[i-1][j].open)) res |= connection(new Node(i-1, j), n2); //check casella sopra
      if ((i+1 < nR) && (node[i+1][j].open)) res |= connection(new Node(i+1, j), n2); //check casella sotto
      if ((j > 0) && (node[i][j-1].open)) res |= connection(new Node(i, j-1), n2); //check casella sopra
      if ((j+1 < nC) && (node[i][j+1].open)) res |= connection(new Node(i, j+1), n2); //check casella sotto
      // il |= basta che ci sia un unico true alle chiamate ricorsive per settare res a true;
    }
    return res;
  }


  //Metodo da richiamare su workingGrid() che conta gli spazi liberi a partire da un nodo...
  //Attenzione: la prima chiamata al metodo deve avvenire su di un nodo libero (open = true)
  //Mi serve passare un parametro intero, ma per riferimento, ma siccome il java è bello e non posso passare
  //l'indirizzo della variabile, allora creo un oggetto counter a tal fine, perchè gli oggetti sono sempre
  //passati per riferimento...
  public int freeSpaces(Node n, Counter count) {
    int i = n.i;
    int j = n.j;

    node[i][j].open = false;
    count.inc();

    if ((i > 0) && (node[i-1][j].open)) freeSpaces(new Node(i-1, j), count);
    if ((i+1 < nR) && (node[i+1][j].open)) freeSpaces(new Node(i+1, j), count);
    if ((j > 0) && (node[i][j-1].open)) freeSpaces(new Node(i, j-1), count);
    if ((j+1 < nC) && (node[i][j+1].open)) freeSpaces(new Node(i, j+1), count);
    return count.c;
  }

  //Metodo da richiamare su workingGrid()
  //Nella prima chiamata occorre passare le coordinate del nodo destinazione, insieme con zero
  public void setValues(int i, int j, int v) { //Setta la griglia dei cammini minimi su tutte le caselle aperte settate a MAX di default, partendo da un Target (0)
    if (node[i][j].n > v) {
      node[i][j].n = v++;

      if ((i > 0) && (node[i-1][j].open)) setValues(i-1, j, v); //Casella sopra (se la riga è > 0)
      if ((i+1 < nR) && (node[i+1][j].open)) setValues(i+1, j, v); //Casella sopra (se la riga è < nR)
      if ((j > 0) && (node[i][j-1].open)) setValues(i, j-1, v); //Casella sinistra (se la colonna è > 0)
      if ((j+1 < nC) && (node[i][j+1].open)) setValues(i, j+1, v); //Casella destra (se la colonna è < nC)
    }
  }

  //Metodo da chiamare su workingGrid()
  //Attenzione: il nodo iHead,jHead deve essere liberato con il metodo free(iHead,jHead) prima di invocare, nell'ordine, i metodi setValues() e shortestPath()
  //Il percorso inizia con il primo nodo accessibile dalla testa dello Snake  etermina con il nodo in cui c'è la mela.
  public ArrayList<Node> shortestPath(int i, int j) { //Ritorna la lista di nodi del cammino minimo, tra la casella selezionata ed il Target (0)
    ArrayList<Node> res = new ArrayList<Node>();
    int n = node[i][j].n;

    while (n != 0) { //Aggiunge nodi fin tanto che non arrivo al Target (0)
      if ((i > 0) && (node[i-1][j].open) && (node[i-1][j].n < n)) { //check casella sopra
        res.add(node[i-1][j]);
        i--; //prossima iterazione sulla casella sopra
      } else if ((i+1 < nR) && (node[i+1][j].open) && (node[i+1][j].n < n)) { //check casella sotto
        res.add(node[i+1][j]);
        i++; //prossima iterazione sulla casella sopra
      } else if ((j > 0) && (node[i][j-1].open) && (node[i][j-1].n < n)) { //check casella destra
        res.add(node[i][j-1]);
        j--; //prossima iterazione sulla casella destra
      } else if ((j+1 < nC) && (node[i][j+1].open) && (node[i][j+1].n < n)) { //check casella sinistra
        res.add(node[i][j+1]);
        j++; //prossima iterazione sulla casella sopra
      }

      n--; //perchè aggiunta ogni casella, la successiva avrà peso minore
    }
    return res;
  }

  public void free(int i, int j) {
    node[i][j].open = true;
    node[i][j].n = nR*nC;
  }

  //Il metodo restituisce tre se nello shortestPath che unisce la testa dello Snake alla mela c'è una restrizione;
  //Altrimenti il metodo restituisce false
  public boolean restriction() {
    boolean res = false;

    Grid wg = workingGrid();
    wg.free(iHead, jHead);
    wg.setValues(iTarget, jTarget, 0);

    ArrayList<Node> sp = wg.shortestPath(iHead, jHead);

    //Adesso occludo, una per volta, ogni casella dello sp, controllando ogni volta che vi sia una connection tra Head e Target
    //se connection ritorna false, allora c'è una restrizione sullo sp;
    for (int i = 0; i < sp.size()-1; i++) { //size()-1 per non considerare la mela
      Node n = sp.get(i);
      wg = workingGrid();
      wg.node[n.i][n.j].open = false; //chiudo il nodo
      if (!wg.connection(new Node(iHead, jHead), new Node(iTarget, jTarget))) { //non c'è connessione...
        res = true;
        break;
      }
    }
    return res;
  }

  //Il metodo va invocato su workingGrid() dopo che si è stabilito l'obiettivo con il metodo setValues()
  //i e j sono le coordinate della Head dello Snake
  //Dovendo eseguire questo metodo ad ogni frame (perchè gli ostacoli sono dati dalla coda dello Snake, che non è fissa perchè ad ogni frame si sposta avanti
  //insieme alla testa) è inutile tornare il percorso per intero, basta semplicemente il passo (nodo) strettamente successivo alla testa.
  public Node longestPathFirstStep(int i, int j) {
    ArrayList<Node> neighbors = new ArrayList<Node>();
    int max = 0;
    Node step = null;

    //Adesso cerco tutte le caselle adiacenti (neighbors) che hanno il peso più alto
    if ((i > 0) && (node[i-1][j].open) && (node[i-1][j].n != nR*nC)) { //check casella sopra
      //Inizialmente dò per scontato che sia il massimo, poi con gli altri controlli vedo se è vero
      max = node[i-1][j].n;
      neighbors.add(node[i-1][j]);
    }
    if ((i+1 < nR) && (node[i+1][j].open) && (node[i+1][j].n != nR*nC) && (node[i+1][j].n >= max)) { //check casella sotto
      if (node[i+1][j].n > max) {
        neighbors.clear();
      }
      max = node[i+1][j].n;
      neighbors.add(node[i+1][j]);
    }
    if ((j > 0) && (node[i][j-1].open) && (node[i][j-1].n != nR*nC) && (node[i][j-1].n >= max)) { //check casella destra
      if (node[i][j-1].n > max) {
        neighbors.clear();
      }
      max = node[i][j-1].n;
      neighbors.add(node[i][j-1]);
    }
    if ((j+1 < nC) && (node[i][j+1].open) && (node[i][j+1].n != nR*nC) && (node[i][j+1].n >= max)) { //check casella sinistra
      if (node[i][j+1].n > max) {
        neighbors.clear();
      }
      neighbors.add(node[i][j+1]);
    }

    if (neighbors.size() == 1) //Se nelle vicinanze c'è solo un nodo con valore alto, lo aggiungo a res e setto (i,j) a lui per il prossimo ciclo...
      return neighbors.get(0);
    else { //Altrimenti se ci sono più nodi asiacenti con lo stesso peso...
      //... tra questi andremo a scegliere il nodo che avrà il maggior numero di nodi adiacenti, occlusi
      max = 0;
      Node node;
      for (int k = 0; k < neighbors.size(); k++) { //alla fine "step" conterrà il prossimo nodo...
        node = neighbors.get(k);
        int cn = closedNeighbors(node);
        if (cn > max) {
          max = cn;
          step = node;
        }
      }
      return step;
    }
  }

  //Metodo accessorio del metodo longestPathFirstStep() (non richiamare direttamente)
  public int closedNeighbors(Node n) { //Ritorna il numero di caselle occluse, adiacenti ad un nodo
    int res = 0;

    //Controlli sui bordi
    if (n.i == 0) res++; //Se il nodo è nella prima riga, sicuramente non possiamo accedere al nodo sopra...
    if (n.i == nR-1) res++;
    if (n.j == 0) res++;
    if (n.j == nC-1) res++; 

    //Controllo su caselle centrali
    if ((n.i > 0) && (!node[n.i-1][n.j].open)) res++; //check sopra
    if ((n.i+1 < nR) && (!node[n.i+1][n.j].open)) res++; //check sotto
    if ((n.j > 0) && (!node[n.i][n.j-1].open)) res++; //check destra
    if ((n.j+1 < nC) && (!node[n.i][n.j+1].open)) res++; //check sinistra

    return res;
  }

  //Attenzione: il metodo si chiama da grid (non workingGrid)
  //ritorna i nodi (e perciò anche il numero di essi) adiacenti ad un nodo (presumibilmente la testa)
  public ArrayList<Node> freeNodes(int i, int j) {
    ArrayList<Node> res = new ArrayList<Node>();

    if ((i > 0) && (node[i-1][j].n <= 0)) res.add(node[i-1][j]); // check casella sotto {'<=' allora la casella è vuota o al più c'è una mela}
    if ((i+1 < nR) && (node[i+1][j].n <= 0)) res.add(node[i+1][j]); // check casella sopra
    if ((j > 0) && (node[i][j-1].n <= 0)) res.add(node[i][j-1]); // check casella destra
    if ((j+1 < nC) && (node[i][j+1].n <= 0)) res.add(node[i][j+1]); // check casella sinistra

    return res;
  }

  //Attenzione: il metodo si chiama su grid (non workingGrid)
  //diminuisce il valore numerico della coda del serpente (per farla scorrere), piazza la testa nella casella successiva,
  //verifica se è stata morsa una mela, in tal caso aumenta lunghezza dello Snake e aggiunge una nuova mela alla grid.
  public void putHead(Node n) {
    if ((n.i == iTarget) && (n.j == jTarget)) { //è stata morsa la mela
      head++;
      newApple();
    } else { //dimuisco la coda per farla scorrere
      for (int i = 0; i < nR; i++) {
        for (int j = 0; j < nC; j++) {
          if (node[i][j].n > 0)
            node[i][j].n--;
        }
      }
    }
    //Adesso aggiorno le coordinate della testa per farla scorrere...
    iHead = n.i;
    jHead = n.j;
    node[iHead][jHead].n = head;
  }

  //Metodo accessorio del metodo putHead() (non richiamare direttamente)
  public void newApple() {
    int i, j;
    do {
      i = floor(random(nR));
      j = floor(random(nC));
    } while (node[i][j].n != 0); //nel caso in cui venisse generata una mella sulla coda o sulla mela attuale...

    iTarget = i;
    jTarget = j;

    node[i][j].n = -1;
  }

  //Metodo da richiamare dalla grid;
  //Mi ritorna il nodo della coda, accessibile alla testa, più vecchio
  public Node oldestPieceOfTail() {
    Node res = null;
    ArrayList<Node> fn;
    int min = nR*nC;

    for (int i = 0; i< nR; i++) {
      for (int j = 0; j < nC; j++) {
        if ((node[i][j].n < min) && (node[i][j].n > 0)) { //Caselle della coda con valore via via più basso...
          Node nod = node[i][j];
          fn = freeNodes(nod.i, nod.j);

          if (fn.size() > 0) { //Ci sono delle caselle libere, devo controlloare se per ciascna di queste caselle di coda c'è una connessione col la Head
          label:

            for (int k = 0; k < fn.size(); k++) {
              Node n = fn.get(k);

              if (workingGrid().connection(new Node(iHead, jHead), n)) { //C'è connessione con la testa
                min = nod.n;
                res = n;
                break label;
              }
            }
          }
        }
      }
    }
    return res;
  }

  //Metodo da richiamare da grid
  //Ritorna la casella in ci è presente la punta della coda...
  public Node tipTail() {
    Node res = null;

  label:
    for (int i = 0; i < nR; i++) {
      for (int j = 0; j < nC; j++) {
        if (node[i][j].n == 1) {
          res = node[i][j];
          break label;
        }
      }
    }
    return res;
  }

  //Metodo da richiamare su grid
  //Mi ritorna la direzione dello Snake
  public Direction direction() {
    //La posizione è data da [iHead-(iHead-1); jHead] & [iHead; jHead-(jHead-1)]
    //Cerco la posizione della testa precedente (head-1) che sarà sopra, sotto, a destra oppure a sinistra della Head
    if ((iHead > 0) && (node[iHead-1][jHead].n == head-1)) return new Direction(1, 0); //La testa si è spostata in basso...
    else if ((iHead+1 < nR) && (node[iHead+1][jHead].n == head-1)) return new Direction(-1, 0); //La testa si è spostata verso l'alto...
    else if ((jHead > 0) && (node[iHead][jHead-1].n == head-1)) return new Direction(0, 1); //La testa si è spostata verso destra...
    else return new Direction(0, -1); //La testa si è spostata verso sinistra...
  }

  //Metodo da richiamare su grid che ritorna una copia della grid
  public Grid copy() {
    Grid res = new Grid();

    for (int i = 0; i < nR; i++) {
      for (int j = 0; j < nC; j++) {
        if (node[i][j].n > 0)
          res.node[i][j].n = node[i][j].n;
      }
    }

    return res;
  }
}
