import processing.serial.*;

Serial myPort;  // Instância do objeto Serial
float angle = 270;  // Ângulo do arco
float bowLength = 200; // Comprimento do arco
float arrowLength = 120; // Comprimento da flecha
float arrowAngle = 90; // Ângulo da flecha em relação ao arco
boolean arrowReleased = false; // Flag para saber se a flecha foi disparada
PVector arrowPosition; // Posição atual da flecha
PVector arrowVelocity; // Velocidade da flecha
PVector targetPosition; // Posição do alvo
int score = 0; // Score inicial
int ammo = 3; // Quantidade inicial de flechas

void setup() {
  size(1000, 800); // Tamanho da janela
  println(Serial.list()); // Listar portas seriais disponíveis
  String portName = Serial.list()[1]; // Selecionar a segunda porta (ajuste se necessário)
  myPort = new Serial(this, portName, 9600); // Iniciar comunicação serial
  myPort.bufferUntil('\n'); // Ler até nova linha
  
  arrowPosition = new PVector(width / 8, height / 2); // Iniciar a flecha na posição à esquerda
  arrowVelocity = new PVector(0, 0); // Velocidade inicial da flecha é zero
  targetPosition = generateRandomTargetPosition(); // Gerar posição inicial aleatória para o alvo
}

void draw() {
  background(255); // Limpar a tela
  
  // Desenhar o arco à esquerda da tela
  pushMatrix(); // Salvar a matriz de transformação atual
  translate(width / 8, height / 2); // Posicionar o arco à esquerda da tela
  rotate(radians(angle)); // Rotacionar de acordo com o ângulo
  drawBow(); // Desenhar o arco
  
  // Se a flecha não foi disparada, desenhá-la no arco
  if (!arrowReleased) {
    drawArrowOnBow(); // Desenhar a flecha no arco
  }
  
  popMatrix(); // Restaurar a matriz de transformação
  
  // Atualizar posição da flecha se ela foi disparada
  if (arrowReleased) {
    arrowPosition.add(arrowVelocity); // Atualizar posição com base na velocidade
    drawFlyingArrow(); // Desenhar a flecha voando
    
    // Verificar se a flecha atingiu o alvo
    if (dist(arrowPosition.x, arrowPosition.y, targetPosition.x, targetPosition.y) < 25) {
      ammo = 3;
      score++; // Incrementar o score se a flecha atingiu o alvo
      resetArrow(); // Resetar a flecha para o arco
      targetPosition = generateRandomTargetPosition(); // Gerar nova posição aleatória para o alvo
    }
    
    // Verificar se a flecha saiu da tela
    if (arrowPosition.x > width || arrowPosition.x < 0 || arrowPosition.y > height || arrowPosition.y < 0) {
      resetArrow(); // Resetar a flecha se sair da tela
    }
  }
  
  // Desenhar o alvo (círculo vermelho)
  fill(255, 0, 0); // Cor vermelha
  noStroke(); // Sem contorno
  ellipse(targetPosition.x, targetPosition.y, 50, 50); // Desenhar o alvo
  
  // Mostrar o score e a munição na tela
  fill(0); // Cor preta
  textSize(24); // Tamanho do texto
  textAlign(CENTER, TOP); // Alinhamento do texto
  text("Pontos: " + score, 100, 20); // Mostrar o score
  text("Flechas: " + ammo, 100, 50); // Mostrar a munição
}

void serialEvent(Serial myPort) {
  String inString = myPort.readStringUntil('\n'); // Ler até nova linha
  if (inString != null) {
    inString = trim(inString); // Remover espaços em branco
    println("Received: " + inString); // Imprimir valor recebido para depuração
    
    // Verificar se a string começa com "Potenciômetro: "
    if (inString.startsWith("Potenciômetro: ")) {
      // Extrair o número após "Potenciômetro: "
      String numString = inString.substring(15); // Ignorar os primeiros 15 caracteres
      try {
        int potValue = Integer.parseInt(numString); // Converter para inteiro
        
        // Mapear para um intervalo maior de ângulos (-130 a 180 graus)
        angle = map(potValue, 0, 1023, -130, 180);
      } catch (NumberFormatException e) {
        println("Erro ao converter para inteiro: " + numString); // Imprimir erro de conversão
      }
    } else {
      println("String recebida não começa com 'Potenciômetro: '");
    }
  }
}

void drawBow() {
  stroke(0); // Cor da linha
  strokeWeight(4); // Espessura da linha
  float halfBowLength = bowLength / 2.0; // Meio comprimento do arco
  line(-halfBowLength, 0, halfBowLength, 0); // Desenhar o arco
  noFill(); // Sem preenchimento
  arc(0, 0, bowLength, bowLength, 0, PI); // Desenhar a corda do arco
}

void drawArrowOnBow() {
  float arrowBaseX = bowLength / 512; // Base da flecha no meio do arco
  float arrowBaseY = 0; // Altura da base da flecha
  
  pushMatrix();
  translate(arrowBaseX, arrowBaseY); // Mover para a base da flecha no arco
  rotate(radians(arrowAngle)); // Rotacionar a flecha em relação ao arco
  stroke(0); // Cor da linha
  strokeWeight(2); // Espessura da linha
  line(0, 0, arrowLength, 0); // Desenhar a linha da flecha
  popMatrix();
}

void drawFlyingArrow() {
  pushMatrix();
  translate(arrowPosition.x, arrowPosition.y); // Mover para a posição atual da flecha
  rotate(arrowVelocity.heading()); // Rotacionar a flecha de acordo com sua direção
  stroke(0); // Cor da linha
  strokeWeight(2); // Espessura da linha
  line(0, 0, arrowLength, 0); // Desenhar a linha da flecha
  popMatrix();
}

void resetArrow() {
  arrowReleased = false; // Resetar flag de flecha disparada
  arrowVelocity = new PVector(0, 0); // Resetar velocidade da flecha
  arrowPosition = new PVector(width / 8, height / 2); // Reposicionar a flecha à esquerda
}

PVector generateRandomTargetPosition() {
  // Gerar uma posição aleatória para o alvo dentro do alcance do arco
  float targetAngle = random(-90, 90); // Ângulo aleatório entre -90 e 90 graus
  float targetX = width - 100; // Posição x fixa (lado direito da tela)
  float targetY = height / 2 + bowLength * sin(radians(targetAngle)); // Posição y com base no ângulo
  return new PVector(targetX, targetY);
}

void keyPressed() {
  if (keyCode == ENTER) { // Tecla Enter para disparar a flecha
    if (!arrowReleased && ammo > 0) {
      // Calcular a velocidade da flecha baseada no ângulo do arco e da flecha
      float arrowSpeed = 18; // Velocidade da flecha
      
      // Calcular o ângulo total (ângulo do arco + ângulo da flecha em relação ao arco)
      float totalAngle = angle + arrowAngle;
      
      // Calcular componentes x e y da velocidade usando seno e cosseno
      float arrowVelocityX = arrowSpeed * cos(radians(totalAngle));
      float arrowVelocityY = arrowSpeed * sin(radians(totalAngle));
      
      arrowVelocity = new PVector(arrowVelocityX, arrowVelocityY); // Definir a velocidade da flecha
      arrowReleased = true; // Marcar que a flecha foi disparada
      ammo--; // Reduzir a munição após disparar a flecha
    }
  }
}
