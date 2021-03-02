int nR = 25;
int nC = 25;

Grid grid;
float dX, dY;

int iHead, jHead;
int head;

int iTarget, jTarget;

ArrayList<Node> sPath;

boolean gameOver;
int pause;

void setup() {
  size(600, 600);

  dX = 1.0*width/nC;
  dY = 1.0*height/nR;

  grid = new Grid();

  iHead = 0;
  jHead = 0;
  head = 1;

  grid.node[iHead][jHead].n = head;

  iTarget = nR-1;
  jTarget = nC-1;

  grid.node[iTarget][jTarget].n = -1;

  gameOver = false;
  pause = 1;
}

void draw() {
  background(90);

  if (pause == 0) {
    grid.display();
    algorithm();
  } else if (pause == 1) {
    grid.display();
    textSize(30);
    textAlign(LEFT);
    fill(190, 190, 0);
    text("Pause", 10, 40);
  } else if (pause == 2) {
    grid.debug1();
    textSize(30);
    textAlign(LEFT);
    fill(80, 80, 0);
    text("debug1", 10, 40);
  } else if (pause == 3) {
    grid.debug2();
    textSize(30);
    textAlign(LEFT);
    fill(80, 80, 0);
    text("debug2", 10, 40);
  }

  //if (!gameOver) {
  //  ArrayList<Node> fn = grid.freeNodes(iHead, jHead);

  //  if (fn.size() == 0) //non ci sono caselle adiacenti la testa...
  //    gameOver = true;
  //  else if (fn.size() == 1) //c'è solo una casella, ci va...
  //    grid.putHead(fn.get(0));
  //  else if (fn.size() >= 2) { //ci sono due caselle libere...
  //    Node n1 = fn.get(0);
  //    Node n2 = fn.get(1);
  //    if (grid.workingGrid().connection(n1, n2)) {
  //      //Se i due nodi sono connessi (*)
  //      if (grid.workingGrid().connection(new Node(iHead, jHead), new Node(iTarget, jTarget))) {
  //        //Se testa dello SNake e mela sono connesse
  //        Grid wg = grid.workingGrid();
  //        if (grid.restriction()) {
  //          //Se il percorso che conduce la testa dello Snake alla mela ha restrizioni
  //          wg.setValues(iTarget, jTarget, 0);
  //          grid.putHead(wg.longestPathFirstStep(iHead, jHead));
  //        } else {
  //          //Se il percorso che conduce la testa dello Snake alla mela NON ha restrizioni
  //          wg.free(iHead, jHead);
  //          wg.setValues(iTarget, jTarget, 0);
  //          grid.putHead(wg.shortestPath(iHead, jHead).get(0));
  //        }
  //      } else {
  //        //Se testa dello Snake e mela non sono connesse
  //        Grid wg = grid.workingGrid();
  //        Node n = grid.oldestPieceOfTail();
  //        wg.setValues(n.i, n.j, 0);
  //        grid.putHead(wg.longestPathFirstStep(iHead, jHead));
  //      }
  //    } else {
  //      //I due nodi sono NON connessi (**)
  //      Node tip = grid.tipTail();
  //      if (grid.workingGrid().connection(tip, n1)) //Il nodo1 è connesso con la punta della coda //Attenzione, può indurre lo snake in loop! PDF
  //        grid.putHead(n1);
  //      else if (grid.workingGrid().connection(tip, n2)) //Il nodo2 è connesso con la punta della coda //Attenzione, può indurre lo snake in loop! PDF
  //        grid.putHead(n2);
  //      else { //In questo caso spostiamo la head nella sezione della griglia dove c'è più spazio disponibile...
  //        Grid wg = grid.workingGrid();
  //        float fs1 = wg.freeSpaces(n1, new Counter());
  //        float fs2 = wg.freeSpaces(n2, new Counter());

  //        if (fs1 > fs2) //lo spazio accessibile a partire dal nodo1 è maggiore rispetto quello accessibile dal nodo2...
  //          grid.putHead(n1);
  //        else
  //          grid.putHead(n2);
  //      }
  //    }
  //  }
  //} else {
  //  textSize(69);
  //  textAlign(CENTER, CENTER);
  //  fill(180, 180, 0);
  //  text("Game Over!", width/2, height/2);
  //  noLoop();
  //}
}

public void keyPressed() {
  if (key == 'p') { //mette in pausa e mostra la vista dello Snake...
    if (pause == 0)
      pause = 1;
    else
      pause = 0;
  }

  if (key == TAB) {
    if (pause == 1)
      pause = 2;
    else if (pause == 2)
      pause = 3;
    else if (pause == 3)
      pause = 2;
  }
}

public void algorithm() {
  if (!gameOver) {
    ArrayList<Node> fn = grid.freeNodes(iHead, jHead);

    if (fn.size() == 0) //non ci sono caselle adiacenti la testa...
      gameOver = true;
    else if (fn.size() == 1) //c'è solo una casella, ci va...
      grid.putHead(fn.get(0));
    else if (fn.size() == 2) { //ci sono due caselle libere...
      Node n1 = fn.get(0);
      Node n2 = fn.get(1);
      twoNodesB(n1, n2);
    } else if (fn.size() == 3) { //ci sono 3 caselle libere...
      Node n1 = fn.get(0);
      Node n2 = fn.get(1);
      Node n3 = fn.get(2);

      if (grid.workingGrid().connection(n1, n2)) { //n1 e n2 sono connessi...
        if (grid.workingGrid().connection(n2, n3)) //n1, n2 e n3 sono connessi tra loro
          twoNodesA();
        else { //n1 e n2 sono connessi, n3 è isolato... (1)
          //Scegliere opportunamente tra n1 e n2 e passarlo insieme a n3 a twoNodesB(), ovvero il nodo che mantiene la direzione dello Snake (traiettoria lineare)
          Direction dir = grid.direction();
          //con l'if controllo se la direzione del passo successivo, ad esempio verso verso il nodo n1, è uguale alla direzione del passo precedente, cioè se lo Snake manterrà la traiettoria
          if ((n1.i-iHead == dir.dI) && (n1.j-jHead == dir.dJ)) twoNodesB(n1, n3);
          else twoNodesB(n2, n3);
        }
      } else { //n1 e n2 NON sono connessi
        if (grid.workingGrid().connection(n2, n3)) { //n1 è isolato, n2 e n3 sono connessi... (2)
          //Scegliere opportunamente tra n1 e n2 e passarlo insieme a n3 a twoNodesB(), ovvero il nodo che mantiene la direzione dello Snake (traiettoria lineare)
          Direction dir = grid.direction();
          //con l'if controllo se la direzione del passo successivo, ad esempio verso il nodo n2, è uguale alla direzione del passo precedente, cioè se lo Snake manterrà la traiettoria
          if ((n2.i-iHead == dir.dI) && (n2.j-jHead == dir.dJ)) twoNodesB(n1, n2);
          else twoNodesB(n1, n3);
        } else { //n1 NON è connesso con n2 che NON è connesso con n3
          if (grid.workingGrid().connection(n1, n3)) { //n1 è connesso con n3, n2 è isolato... (3)
            //Scegliere opportunamente tra n1 e n2 e passarlo insieme a n3 a twoNodesB(), ovvero il nodo che mantiene la direzione dello Snake (traiettoria lineare)
            Direction dir = grid.direction();
            //con l'if controllo se la direzione del passo successivo, ad esempio verso il nodo n1, è uguale alla direzione del passo precedente, cioè se lo Snake manterrà la traiettoria
            if ((n1.i-iHead == dir.dI) && (n1.j-jHead == dir.dJ)) twoNodesB(n1, n2);
            else twoNodesB(n3, n2);
          } else { //tutti e tre i nodi sono isolati...
            Grid wg = grid.workingGrid();
            float fs1 = wg.freeSpaces(n1, new Counter());
            float fs2 = wg.freeSpaces(n2, new Counter());
            float fs3 = wg.freeSpaces(n3, new Counter());

            if (fs1 >= fs2) {
              if (fs2 >= fs3) // fs3 è il minore tra tutti...
                twoNodesB(n1, n2);
              else // fs2 è il minore tra tutti...
              twoNodesB(n1, n3);
            } else { //fs2 è maggiore di fs1
              if (fs3 >= fs1) //fs1 è il minore...
                twoNodesB(n2, n3);
              else //fs3 è il minore...
              twoNodesB(n1, n2);
            }
          }
        }
      }
    }
  } else {
    textSize(69);
    textAlign(CENTER, CENTER);
    fill(180, 180, 0);
    text("Game Over!", width/2, height/2);
  }
}

public void twoNodesA() {
  if (grid.workingGrid().connection(new Node(iHead, jHead), new Node(iTarget, jTarget))) {
    //Se testa dello SNake e mela sono connesse
    Grid wg = grid.workingGrid();
    if (grid.restriction()) {
      //Se il percorso che conduce la testa dello Snake alla mela ha restrizioni
      wg.setValues(iTarget, jTarget, 0);
      grid.putHead(wg.longestPathFirstStep(iHead, jHead));
    } else {
      //Se il percorso che conduce la testa dello Snake alla mela NON ha restrizioni //ATTENZIONE LOOP
      wg.free(iHead, jHead);
      wg.setValues(iTarget, jTarget, 0);
      //la testa dello snake non deve disconnettere la mela con la punta della coda //risolve il bug del loop
      Node step = wg.shortestPath(iHead, jHead).get(0);
      if ((step.i == iTarget) && (step.j == jTarget)) //se il prossimo passo è verso la mela...
        grid.putHead(step);
      else { //altrimento fare quel controllo della connessione...
        //creo una copia della griglia su cui simulare questo passo, e controllo su essa se interrompe la connessione...
        Grid g2 = grid.copy();
        g2.node[step.i][step.j].n = head;
        Node tip = g2.tipTail();
        if (g2.workingGrid().connection(tip, new Node(iTarget, jTarget))) //c'è connessione... si prosegue normalmente
          grid.putHead(step);
        else { //non c'è connessione... cerco un altro percorso (minimo verso la mela)
          wg = g2.workingGrid();
          wg.free(iHead, jHead);
          wg.setValues(iTarget, jTarget, 0);
          grid.putHead(wg.shortestPath(iHead, jHead).get(0));
        }
      }
    }
  } else {
    //Se testa dello Snake e mela non sono connesse
    Grid wg = grid.workingGrid();
    Node n = grid.oldestPieceOfTail();
    wg.setValues(n.i, n.j, 0);
    grid.putHead(wg.longestPathFirstStep(iHead, jHead));
  }
}

public void twoNodesB(Node n1, Node n2) {
  if (grid.workingGrid().connection(n1, n2)) {
    //Se i due nodi sono connessi (*)
    twoNodesA();
  } else {
    //I due nodi sono NON connessi (**)
    Node tip = grid.tipTail();
    if (grid.workingGrid().connection(tip, n1)) //Il nodo1 è connesso con la punta della coda //Attenzione, può indurre lo snake in loop! PDF
      grid.putHead(n1);
    else if (grid.workingGrid().connection(tip, n2)) //Il nodo2 è connesso con la punta della coda //Attenzione, può indurre lo snake in loop! PDF
      grid.putHead(n2);
    else { //In questo caso spostiamo la head nella sezione della griglia dove c'è più spazio disponibile...
      Grid wg = grid.workingGrid();
      float fs1 = wg.freeSpaces(n1, new Counter());
      float fs2 = wg.freeSpaces(n2, new Counter());

      if (fs1 > fs2) //lo spazio accessibile a partire dal nodo1 è maggiore rispetto quello accessibile dal nodo2...
        grid.putHead(n1);
      else
        grid.putHead(n2);
    }
  }
}
