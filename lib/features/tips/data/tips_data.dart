import '../domain/enums/tip_category.dart';
import '../domain/models/tip.dart';

/// Static database of financial tips.
/// Organized by category for contextual selection.
class TipsData {
  TipsData._();

  /// All available tips.
  static const List<Tip> allTips = [
    // ============================================
    // INVESTMENT TIPS (Budget > 50%)
    // ============================================
    Tip(
      id: 'inv_01',
      category: TipCategory.investment,
      content:
          'Avec ce surplus, pense à investir 10% de ton budget. Ton futur toi te remerciera!',
    ),
    Tip(
      id: 'inv_02',
      category: TipCategory.investment,
      content:
          'Les intérêts composés sont magiques: 10 000 FCFA/mois à 5% = 1,5 million en 10 ans.',
    ),
    Tip(
      id: 'inv_03',
      category: TipCategory.investment,
      content:
          'Diversifie tes investissements: ne mets jamais tous tes oeufs dans le même panier.',
    ),
    Tip(
      id: 'inv_04',
      category: TipCategory.investment,
      content:
          'Renseigne-toi sur les tontines digitales - un moyen traditionnel modernisé d\'épargner.',
    ),
    Tip(
      id: 'inv_05',
      category: TipCategory.investment,
      content:
          'L\'investissement le plus rentable? Toi-même. Formation, livres, compétences.',
    ),

    // ============================================
    // SAVINGS TIPS (Budget > 50%)
    // ============================================
    Tip(
      id: 'sav_01',
      category: TipCategory.savings,
      content:
          'Bravo pour ta gestion! Profite pour constituer ton fonds d\'urgence de 6 mois.',
    ),
    Tip(
      id: 'sav_02',
      category: TipCategory.savings,
      content:
          'Règle d\'or: Paie-toi en premier. Épargne dès que tu reçois ton salaire.',
    ),
    Tip(
      id: 'sav_03',
      category: TipCategory.savings,
      content:
          'Automatise ton épargne: ce que tu ne vois pas, tu ne le dépenses pas.',
    ),
    Tip(
      id: 'sav_04',
      category: TipCategory.savings,
      content:
          'Objectif: 3 à 6 mois de dépenses en épargne de sécurité avant tout investissement.',
    ),
    Tip(
      id: 'sav_05',
      category: TipCategory.savings,
      content:
          'Chaque surplus est une opportunité. Même 1 000 FCFA épargnés comptent!',
    ),

    // ============================================
    // OPTIMIZATION TIPS (Budget 20-50%)
    // ============================================
    Tip(
      id: 'opt_01',
      category: TipCategory.optimization,
      content:
          'Astuce: Les courses en gros au marché coûtent 20-30% moins cher qu\'au détail.',
    ),
    Tip(
      id: 'opt_02',
      category: TipCategory.optimization,
      content:
          'Révise tes abonnements: combien n\'utilises-tu plus vraiment?',
    ),
    Tip(
      id: 'opt_03',
      category: TipCategory.optimization,
      content:
          'Préparer ses repas à la maison peut économiser jusqu\'à 50% vs manger dehors.',
    ),
    Tip(
      id: 'opt_04',
      category: TipCategory.optimization,
      content:
          'Compare les prix avant d\'acheter. 5 minutes peuvent sauver 5 000 FCFA.',
    ),
    Tip(
      id: 'opt_05',
      category: TipCategory.optimization,
      content:
          'Négocie! En Afrique, presque tout se négocie. N\'aie pas peur de demander.',
    ),

    // ============================================
    // ECONOMY TIPS (Budget 20-50%)
    // ============================================
    Tip(
      id: 'eco_01',
      category: TipCategory.economy,
      content:
          'Les petits achats s\'additionnent vite. Un café à 500 FCFA/jour = 15 000 FCFA/mois!',
    ),
    Tip(
      id: 'eco_02',
      category: TipCategory.economy,
      content:
          'Règle des 24h: Attends 24h avant tout achat impulsif. Le désir passe souvent.',
    ),
    Tip(
      id: 'eco_03',
      category: TipCategory.economy,
      content:
          'Distingue besoins et envies. Les besoins d\'abord, les envies si possible.',
    ),
    Tip(
      id: 'eco_04',
      category: TipCategory.economy,
      content:
          'Le covoiturage ou les transports en commun peuvent réduire tes frais de 40%.',
    ),
    Tip(
      id: 'eco_05',
      category: TipCategory.economy,
      content:
          'Éteins les appareils en veille. Ça peut réduire ta facture d\'électricité de 10%.',
    ),

    // ============================================
    // SURVIVAL TIPS (Budget < 20%)
    // ============================================
    Tip(
      id: 'sur_01',
      category: TipCategory.survival,
      content:
          'Période serrée? Concentre-toi sur l\'essentiel: logement, nourriture, transport.',
    ),
    Tip(
      id: 'sur_02',
      category: TipCategory.survival,
      content:
          'Liste tes dépenses par priorité. Coupe temporairement le non-essentiel.',
    ),
    Tip(
      id: 'sur_03',
      category: TipCategory.survival,
      content:
          'Cherche des revenus complémentaires: petits services, vente d\'objets inutilisés.',
    ),
    Tip(
      id: 'sur_04',
      category: TipCategory.survival,
      content:
          'Contacte tes créanciers si besoin. Mieux vaut négocier que fuir.',
    ),
    Tip(
      id: 'sur_05',
      category: TipCategory.survival,
      content:
          'Chaque FCFA compte. Note toutes tes dépenses pour voir où ça part.',
    ),

    // ============================================
    // SUPPORT TIPS (Budget < 20%) - Emotional
    // ============================================
    Tip(
      id: 'sup_01',
      category: TipCategory.support,
      content:
          'Les difficultés financières sont temporaires. Tu as traversé des moments durs avant.',
    ),
    Tip(
      id: 'sup_02',
      category: TipCategory.support,
      content:
          'Tu gères mieux que tu ne le penses. Chaque jour où tu tiens est une victoire.',
    ),
    Tip(
      id: 'sup_03',
      category: TipCategory.support,
      content:
          'N\'aie pas honte de demander de l\'aide. La solidarité est une force, pas une faiblesse.',
    ),
    Tip(
      id: 'sup_04',
      category: TipCategory.support,
      content:
          'Respire. Le stress ne résout rien. Une solution existe, tu vas la trouver.',
    ),
    Tip(
      id: 'sup_05',
      category: TipCategory.support,
      content:
          'Ce n\'est pas la fin. C\'est juste un chapitre difficile. La suite sera meilleure.',
    ),
  ];

  /// Get tips for a specific category.
  static List<Tip> byCategory(TipCategory category) {
    return allTips.where((tip) => tip.category == category).toList();
  }

  /// Get tips appropriate for a budget percentage.
  static List<Tip> forBudgetPercentage(double percentage) {
    final categories = TipCategory.forBudgetPercentage(percentage);
    return allTips
        .where((tip) => categories.contains(tip.category))
        .toList();
  }
}
