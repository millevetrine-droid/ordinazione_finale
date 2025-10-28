import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import '../../../models/cliente_model.dart';

class PointsSelectionDialog extends StatelessWidget {
  final Cliente user;
  final int puntiGuadagnati;
  final VoidCallback onNonAccumulare;
  final VoidCallback onAccumulaPunti;
  final bool sceltaGiaFatta; // CORRETTO: rimosso accento

  const PointsSelectionDialog({
    super.key,
    required this.user,
    required this.puntiGuadagnati,
    required this.onNonAccumulare,
    required this.onAccumulaPunti,
    this.sceltaGiaFatta = false, // CORRETTO: rimosso accento
  });

  @override
  Widget build(BuildContext context) {
    final nome = user.nome;
    final puntiAttuali = user.punti;
    final nuoviPuntiTotali = puntiAttuali + puntiGuadagnati;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacitySafe(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sceltaGiaFatta ? 'CONFERMA ACCUMULO PUNTI' : 'ACCUMULA PUNTI',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Ciao $nome!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Punti attuali: $puntiAttuali',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Con questo ordine guadagnerai:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              '+$puntiGuadagnati punti 🎉',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Totale: $nuoviPuntiTotali punti',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              sceltaGiaFatta 
                  ? 'I punti verranno automaticamente aggiunti al tuo account! 🎊'
                  : '💰 Accumulando punti sbloccherai automaticamente:\n• Menu esclusivi\n• Drink in omaggio\n• Piatti scontati\n• E molto altro!',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            
            // 👇 LOGICA PULSANTI MODIFICATA
            if (!sceltaGiaFatta) 
              // CASO 1: Prima scelta - mostra entrambi i pulsanti
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNonAccumulare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.black.withOpacitySafe(0.3),
                      ),
                      child: const Text(
                        'NON ACCUMULARE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccumulaPunti,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.black.withOpacitySafe(0.3),
                      ),
                      child: const Text(
                        'ACCUMULA PUNTI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else 
              // CASO 2: Scelta già fatta - mostra solo "PROSEGUI"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccumulaPunti,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: Colors.black.withOpacitySafe(0.3),
                  ),
                  child: const Text(
                    'PROSEGUI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}