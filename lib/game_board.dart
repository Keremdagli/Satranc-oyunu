import 'package:flutter/material.dart';
import 'components/dead_piece.dart';
import 'components/piece.dart';
import 'components/square.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Satranç tahtasını temsil eden 2 boyutlu liste, her eleman
  // bir ChessPiece referansı içerebilir.
  late List<List<ChessPiece?>> board;

  // Satranç tahtasında şu anda seçili olan taş. Eğer seçili taş yoksa bu null'dır.
  ChessPiece? selectedPiece;

  // Tahtada seçili taşın satır indeksi.
  // Varsayılan değer -1, seçili taş olmadığını belirtir.
  int selectedRow = -1;

  // Tahtada seçili taşın sütun indeksi.
  // Varsayılan değer -1, seçili taş olmadığını belirtir.
  int selectedCol = -1;

  // Şu anda seçili olan taşın geçerli hamleleri.
  // Her hamle, satır ve sütun indekslerini içeren iki elemanlı bir liste olarak temsil edilir.
  List<List<int>> validMoves = [];

  // Oynama sırasının kimde olduğunu belirten boolean: true beyaz, false siyah.
  bool isWhiteTurn = true;

  // Siyah oyuncu tarafından alınan beyaz taşların listesi.
  List<ChessPiece> whitePiecesTaken = [];

  // Beyaz oyuncu tarafından alınan siyah taşların listesi.
  List<ChessPiece> blackPiecesTaken = [];

  // Şahın tehdit altında olup olmadığını belirten boolean.
  bool checkStatus = false;

  // Şahların başlangıç pozisyonları
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  // TAHTAYI BAŞLAT
  void _initializeBoard() {
    // Tahtayı null'larla başlat, yani taş yok
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (_) => List.generate(8, (_) => null));

    // Piyonları yerleştir
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png');
    }

    // Kaleleri yerleştir
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');

    // Atları yerleştir
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');

    // Filleri yerleştir
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');

    // Vezirleri yerleştir
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png');
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png');

    // Şahları yerleştir
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png');
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png');

    board = newBoard;
  }

  // KULLANICI BİR TAŞ SEÇTİ
  void pieceSelected(int row, int col) {
    setState(() {
      // Henüz bir taş seçilmedi, bu ilk seçim
      if (selectedPiece == null && board[row][col] != null) {
        // Eğer seçilen kare beyazsa ve beyazın sırasıysa, kullanıcı bu taşı seçebilir
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      // Zaten bir taş seçili, ancak kullanıcı başka bir taşını seçebilir
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      // Bir taş seçili ve tıklanan kare geçerli bir hamle
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // İlk seçimden sonra bir taş seçilirse, geçerli hamlelerini hesapla
      if (selectedPiece != null) {
        validMoves =
            calculateValidMoves(selectedRow, selectedCol, selectedPiece, true);
      }
    });
  }

  // GEÇERLİ HAMLELERİ HESAPLA
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    // Renklerine göre farklı yönler
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Piyon mantığını uygula
        // Piyonlar, kare boşsa ileri hareket edebilir
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Piyonlar, başlangıç pozisyonlarındaysa iki kare ileri hareket edebilir
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Piyonlar çapraz olarak taş alabilir
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        // Yatay ve dikey yönler
        var directions = [
          [-1, 0], // yukarı
          [1, 0], // aşağı
          [0, -1], // sol
          [0, 1], // sağ
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // taş alma
              }
              break; // engellendi
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
        // Atın hareket edebileceği sekiz olası L şekli
        var knightMoves = [
          [-2, -1], // yukarı 2 sol 1
          [-2, 1], // yukarı 2 sağ 1
          [-1, -2], // yukarı 1 sol 2
          [-1, 2], // yukarı 1 sağ 2
          [1, -2], // aşağı 1 sol 2
          [1, 2], // aşağı 1 sağ 2
          [2, -1], // aşağı 2 sol 1
          [2, 1], // aşağı 2 sağ 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // taş alma
            }
            continue; // engellendi
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;

      case ChessPieceType.bishop:
        // Çapraz yönler
        var directions = [
          [-1, -1], // yukarı sol
          [-1, 1], // yukarı sağ
          [1, -1], // aşağı sol
          [1, 1], // aşağı sağ
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // taş alma
              }
              break; // engellendi
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.queen:
        // Sekiz yön: yukarı, aşağı, sol, sağ ve dört çapraz
        var directions = [
          [-1, 0], // yukarı
          [1, 0], // aşağı
          [0, -1], // sol
          [0, 1], // sağ
          [-1, -1], // yukarı sol
          [-1, 1], // yukarı sağ
          [1, -1], // aşağı sol
          [1, 1], // aşağı sağ
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // taş alma
              }
              break; // engellendi
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.king:
        // Sekiz yön: yukarı, aşağı, sol, sağ ve dört çapraz
        var directions = [
          [-1, 0], // yukarı
          [1, 0], // aşağı
          [0, -1], // sol
          [0, 1], // sağ
          [-1, -1], // yukarı sol
          [-1, 1], // yukarı sağ
          [1, -1], // aşağı sol
          [1, 1], // aşağı sağ
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // taş alma
            }
            continue; // engellendi
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
    }

    return candidateMoves;
  }

  // GERÇEK GEÇERLİ HAMLELERİ HESAPLA
  List<List<int>> calculateValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> validMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // Taş için tüm aday hamleleri oluşturduktan sonra, şahın tehdit altında olup olmadığını kontrol et.
    if (checkSimulation) {
      for (List<int> candidateMove in candidateMoves) {
        int endRow = candidateMove[0];
        int endCol = candidateMove[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          validMoves.add(candidateMove);
        }
      }
    } else {
      validMoves = candidateMoves;
    }

    return validMoves;
  }

  // TAŞI YENİ KONUMA TAŞI
  void movePiece(int newRow, int newCol) {
    // Eğer yeni konumda bir taş varsa
    if (board[newRow][newCol] != null) {
      // Alınan taşı uygun listeye ekle
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // Taşın şah olup olmadığını kontrol et
    if (selectedPiece!.type == ChessPieceType.king) {
      // Uygun şah pozisyonunu güncelle
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Taşı hareket ettir ve eski konumu temizle
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Herhangi bir şahın tehdit altında olup olmadığını kontrol et
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // Seçimi temizle
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // Sıra değiştir
    isWhiteTurn = !isWhiteTurn;

    // Şah mat olup olmadığını kontrol et
    if (isCheckMate(isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "ŞAH MAT!",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            // Tekrar oyna butonu
            TextButton(
              onPressed: resetGame,
              child: const Text("Tekrar Oyna"),
            )
          ],
        ),
      );
    }
  }

  // ŞAH TEHDİT ALTINDA MI KONTROL ET
  bool isKingInCheck(bool isWhiteKing) {
    // Şahın pozisyonunu al
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // Herhangi bir düşman taşının şahı tehdit edip etmediğini kontrol et
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Boş kareleri ve şah ile aynı renkteki taşları atla
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, board[i][j], false);

        // Şahın pozisyonunun bu taşın geçerli hamlelerinde olup olmadığını kontrol et
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }

    return false;
  }

  // GELECEK BİR HAMLEYİ SİMÜLE ET VE GÜVENLİ OLUP OLMADIĞINI KONTROL ET (ŞAHI TEHDİT ALTINA ALMAZ!)
  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // Mevcut tahtanın durumunu kaydet
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // Eğer taş şah ise, mevcut pozisyonunu kaydet ve yeni pozisyona güncelle
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // Şahın pozisyonunu güncelle
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // Hamleyi simüle et
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // Kendi şahımızın tehdit altında olup olmadığını kontrol et
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // Tahtayı orijinal durumuna geri yükle
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // Eğer taş şah ise, orijinal pozisyonunu geri yükle
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    return !kingInCheck;
  }

  // ŞAH MAT MI?
  bool isCheckMate(bool isWhiteKing) {
    // Eğer şah tehdit altında değilse, şah mat değildir.
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // Eğer oyuncunun taşlarından herhangi biri için en az bir yasal hamle varsa, şah mat değildir.
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Boş kareleri ve diğer renkteki taşları atla
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, board[i][j], true);

        // Eğer bu taşın herhangi bir geçerli hamlesi varsa, şah mat değildir.
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // Eğer buraya kadar geldiysek, yasal hamle yoktur ve şah mat olmuştur.
    return true;
  }

  // OYUN BİTTİ, OYUNU SIFIRLA
  void resetGame() {
    _initializeBoard();
    checkStatus = false;
    isWhiteTurn = true; // Beyazın sırasıyla oyuna başlanması için ekledik
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BEYAZ TAŞLAR ALINDI
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: whitePiecesTaken.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => DeadPiece(
                  imagePath: whitePiecesTaken[index].imagePath,
                  isWhite: true,
                ),
              ),
            ),
          ),

          // OYUN DURUMU
          Text(
            checkStatus ? "ŞAH!" : "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.grey[800],
            ),
          ),

          // SATRANÇ TAHTASI
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                // Karenin satır ve sütun pozisyonunu al
                int row = index ~/ 8;
                int col = index % 8;

                // Bu karenin seçili olup olmadığını kontrol et
                bool isSelected = row == selectedRow && col == selectedCol;

                // Bu karenin geçerli bir hamle olup olmadığını kontrol et
                bool isValidMove = false;
                for (var position in validMoves) {
                  // Satır ve sütunu karşılaştır
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  onTap: () => pieceSelected(row, col),
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                );
              },
            ),
          ),

          // SİYAH TAŞLAR ALINDI
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: blackPiecesTaken.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => DeadPiece(
                  imagePath: blackPiecesTaken[index].imagePath,
                  isWhite: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
