/// Tutorial content for all app features.
///
/// Each tutorial explains:
/// 1. What the feature is
/// 2. How it works in real life
/// 3. How to use it in the app
class TutorialContent {
  TutorialContent._();

  // ==========================================
  // Règle 50/30/20
  // ==========================================
  static const rule503020 = FeatureTutorial(
    title: 'La Règle 50/30/20',
    emoji: '📊',
    sections: [
      TutorialSection(
        title: 'C\'est quoi?',
        content: '''
La règle 50/30/20 est une méthode simple pour gérer ton budget mensuel. Elle divise tes revenus en trois catégories:

• **50% pour les Besoins** - Les dépenses essentielles dont tu ne peux pas te passer
• **30% pour les Envies** - Les plaisirs et le lifestyle
• **20% pour l'Épargne** - Ton futur financier
''',
      ),
      TutorialSection(
        title: 'Dans la vraie vie',
        content: '''
**Exemple avec un salaire de 300 000 FCFA:**

🏠 **Besoins (150 000 FCFA):**
- Loyer: 80 000 FCFA
- Transport: 25 000 FCFA
- Courses alimentaires: 35 000 FCFA
- Factures (eau, électricité): 10 000 FCFA

🎉 **Envies (90 000 FCFA):**
- Restaurants/sorties: 40 000 FCFA
- Shopping: 30 000 FCFA
- Loisirs: 20 000 FCFA

💰 **Épargne (60 000 FCFA):**
- Fonds d'urgence: 40 000 FCFA
- Investissement: 20 000 FCFA
''',
      ),
      TutorialSection(
        title: 'Dans Pockii',
        content: '''
**Comment l'utiliser:**

1. Active la règle dans **Paramètres > Règle 50/30/20**
2. Pockii calcule automatiquement la répartition selon ton budget mensuel
3. Tu vois les montants cibles pour chaque catégorie

**Astuce:** Commence par noter tes dépenses pendant 1 mois pour voir où va ton argent, puis ajuste progressivement vers la règle 50/30/20.
''',
      ),
    ],
  );

  // ==========================================
  // Fonds d'Urgence
  // ==========================================
  static const emergencyFund = FeatureTutorial(
    title: 'Le Fonds d\'Urgence',
    emoji: '🛡️',
    sections: [
      TutorialSection(
        title: 'C\'est quoi?',
        content: '''
Un fonds d'urgence est une réserve d'argent pour faire face aux imprévus de la vie:

• Perte d'emploi
• Problème de santé
• Réparation urgente (voiture, maison)
• Dépense familiale imprévue

**L'objectif recommandé:** 3 à 6 mois de salaire épargné.
''',
      ),
      TutorialSection(
        title: 'Pourquoi 6 mois?',
        content: '''
**6 mois de salaire te permettent de:**

✅ Chercher un nouvel emploi sans stress financier
✅ Faire face à une hospitalisation
✅ Gérer une urgence familiale
✅ Ne pas t'endetter en cas de coup dur

**Exemple:** Avec un salaire de 250 000 FCFA, ton objectif serait 1 500 000 FCFA (6 × 250 000).
''',
      ),
      TutorialSection(
        title: 'Comment y arriver?',
        content: '''
**Stratégie progressive:**

1. **Mois 1-3:** Épargne 10% de ton salaire
2. **Mois 4-6:** Augmente à 15% si possible
3. **Continue** jusqu'à atteindre 6 mois

**Dans Pockii:**
- Configure ton salaire mensuel
- Choisis ton objectif (3, 6, 9 ou 12 mois)
- Mets à jour ton épargne actuelle
- Suis ta progression!

**Astuce:** Mets ton épargne sur un compte séparé pour ne pas y toucher.
''',
      ),
    ],
  );

  // ==========================================
  // Abonnements
  // ==========================================
  static const subscriptions = FeatureTutorial(
    title: 'Gestion des Abonnements',
    emoji: '🔄',
    sections: [
      TutorialSection(
        title: 'Pourquoi suivre?',
        content: '''
Les abonnements sont des "fuites" silencieuses de ton budget:

• Netflix, Spotify, Canal+
• Forfait mobile, internet
• Assurances
• Abonnements apps

**Le piège:** On oublie souvent ce qu'on paie automatiquement chaque mois!
''',
      ),
      TutorialSection(
        title: 'Dans Pockii',
        content: '''
**Ajoute tes abonnements pour:**

✅ Voir le total mensuel prélevé
✅ Recevoir des rappels avant chaque prélèvement
✅ Identifier les abonnements inutilisés
✅ Avoir ce montant déduit de ton budget disponible

**Astuce:** Fais un audit chaque 3 mois - annule ce que tu n'utilises plus!
''',
      ),
    ],
  );

  // ==========================================
  // Dépenses Prévues
  // ==========================================
  static const plannedExpenses = FeatureTutorial(
    title: 'Dépenses Prévues',
    emoji: '📅',
    sections: [
      TutorialSection(
        title: 'C\'est quoi?',
        content: '''
Les dépenses prévues sont des achats planifiés à l'avance:

• Anniversaire à venir
• Rentrée scolaire
• Voyage prévu
• Achat important (électroménager, etc.)

**L'avantage:** Tu peux les anticiper et épargner progressivement!
''',
      ),
      TutorialSection(
        title: 'Dans Pockii',
        content: '''
**Comment ça marche:**

1. Ajoute une dépense avec le montant et la date prévue
2. Pockii la déduit de ton budget disponible
3. Tu reçois un rappel quand la date approche
4. Marque-la comme payée quand c'est fait

**Astuce:** Ajoute les dépenses annuelles (impôts, assurance voiture) dès maintenant!
''',
      ),
    ],
  );
}

/// A complete tutorial for a feature.
class FeatureTutorial {
  const FeatureTutorial({
    required this.title,
    required this.emoji,
    required this.sections,
  });

  final String title;
  final String emoji;
  final List<TutorialSection> sections;
}

/// A section within a tutorial.
class TutorialSection {
  const TutorialSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}
