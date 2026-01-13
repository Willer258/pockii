# Pockii

<p align="center">
  <img src="assets/branding/pockii_logo_1024.png" alt="Pockii Logo" width="150"/>
</p>

<p align="center">
  <strong>Ton budget, simplifié.</strong>
</p>

<p align="center">
  Application de gestion de budget personnel conçue pour les utilisateurs de la zone FCFA.
</p>

---

## Fonctionnalités

### Budget & Dépenses
- **Suivi du budget en temps réel** - Visualise ton budget restant instantanément
- **Ajout rapide de dépenses** - Clavier numérique optimisé pour une saisie fluide
- **Catégorisation intelligente** - Organise tes dépenses par catégorie
- **Historique complet** - Consulte toutes tes transactions passées

### Abonnements
- **Gestion des abonnements** - Netflix, Spotify, loyer... tout au même endroit
- **Rappels automatiques** - Notifications avant chaque échéance
- **Impact sur le budget** - Vois l'effet de tes abonnements sur ton budget

### Dépenses Prévues
- **Planification des grosses dépenses** - Anticipe tes achats importants
- **Notifications de rappel** - Ne rate jamais une échéance
- **Projection du budget** - Visualise ton solde après engagements

### Règle 50/30/20 & Épargne
- **Répartition budgétaire intelligente** - Applique automatiquement la règle 50/30/20
  - 🏠 **Besoins (50%)** - Loyer, transport, alimentation de base
  - 🎉 **Envies (30%)** - Loisirs, restaurants, shopping
  - 💰 **Épargne (20%)** - Économies et investissements
- **Classification automatique** - Chaque dépense est mappée à sa catégorie budget
- **Feedback en temps réel** - Vois l'impact de chaque dépense sur ton budget avant de valider
- **Alertes de dépassement** - Notification visuelle quand tu dépasses une catégorie

### Fonds d'Urgence
- **Objectif 6 mois de salaire** - Configure ton objectif d'épargne de sécurité
- **Progression visuelle** - Barre de progression motivante
- **Auto-incrémentation** - Les dépenses "Épargne" s'ajoutent automatiquement au fonds
- **Messages motivants** - Conseils personnalisés selon ta progression

### Gamification
- **Système de streaks** - Maintiens ta série de jours de suivi
- **Célébrations** - Récompenses pour ta régularité (7, 14, 30, 60, 90 jours...)
- **Badges de progression** - Motive-toi avec des objectifs visuels
- **Statut budget 50/30/20** - Bonus visuel si tu respectes ta répartition

### Notifications Intelligentes
- **Alertes budget** - Avertissement à 30% et 10% du budget restant
- **Rappels d'abonnements** - 2 jours avant chaque prélèvement
- **Limite quotidienne** - Maximum 5 notifications/jour pour éviter le spam

---

## Captures d'écran

<p align="center">
  <i>Screenshots à venir</i>
</p>

---

## Stack Technique

| Catégorie | Technologie |
|-----------|-------------|
| **Framework** | Flutter 3.38+ |
| **Langage** | Dart 3.3+ |
| **State Management** | Riverpod 2.6 |
| **Base de données** | Drift + SQLCipher (chiffré) |
| **Navigation** | GoRouter |
| **Background Tasks** | WorkManager |
| **Notifications** | flutter_local_notifications |
| **Stockage sécurisé** | flutter_secure_storage |

---

## Architecture

```
lib/
├── core/                    # Services et utilitaires partagés
│   ├── constants/           # Constantes de l'app
│   ├── database/            # Configuration Drift + DAOs
│   ├── router/              # Configuration GoRouter
│   ├── services/            # Services (notifications, background, etc.)
│   └── theme/               # Thème Material Design 3
│
├── features/                # Fonctionnalités par domaine
│   ├── budget/              # Gestion des périodes budgétaires
│   ├── budget_rules/        # Règle 50/30/20 & Fonds d'urgence
│   │   ├── domain/          # Modèles (BudgetAllocation, EmergencyFund)
│   │   ├── data/            # Repository SharedPreferences
│   │   └── presentation/    # Widgets (BudgetAllocationCard, EmergencyFundCard)
│   ├── history/             # Historique des transactions
│   ├── home/                # Écran d'accueil + BudgetHeroCard
│   ├── onboarding/          # Parcours d'inscription
│   ├── planned_expenses/    # Dépenses prévues
│   ├── settings/            # Paramètres
│   ├── shell/               # Navigation principale
│   ├── streaks/             # Système de streaks + intégration 50/30/20
│   ├── subscriptions/       # Gestion des abonnements
│   ├── tips/                # Conseils financiers contextuels
│   └── transactions/        # Ajout/édition de transactions + feedback budget
│
└── shared/                  # Widgets et utilitaires partagés
    ├── utils/               # Formatters (FCFA, dates)
    └── widgets/             # Widgets réutilisables
```

---

## Installation

### Prérequis
- Flutter SDK 3.38+
- Dart SDK 3.3+
- Android Studio / Xcode

### Étapes

```bash
# Cloner le repo
git clone https://github.com/Willer258/pockii.git
cd pockii

# Installer les dépendances
flutter pub get

# Générer les fichiers Drift
dart run build_runner build

# Lancer l'app
flutter run
```

### Générer les icônes (si nécessaire)

```bash
dart run flutter_launcher_icons
```

---

## Configuration

### Base de données chiffrée
L'app utilise SQLCipher pour chiffrer toutes les données localement. La clé de chiffrement est générée automatiquement et stockée de manière sécurisée via `flutter_secure_storage`.

### Notifications
Les notifications sont gérées via `flutter_local_notifications` avec deux canaux :
- **Pockii Notifications** - Notifications standard
- **Pockii Alertes** - Alertes critiques (budget < 10%)

---

## Tests

```bash
# Tests unitaires
flutter test test/unit/

# Tests de widgets
flutter test test/widget/

# Tous les tests
flutter test
```

---

## Roadmap

### Terminé
- [x] Règle budgétaire 50/30/20 avec suivi automatique
- [x] Fonds d'urgence (objectif 6 mois de salaire)
- [x] Classification intelligente des dépenses
- [x] Feedback en temps réel lors de la saisie
- [x] Intégration streaks + respect du budget
- [x] Analyse des patterns de dépenses

### À venir
- [ ] Mode sombre
- [ ] Export des données (CSV/PDF)
- [ ] Synchronisation cloud (optionnelle)
- [ ] Multi-devises
- [ ] Tutoriels interactifs

---

## Contribution

Les contributions sont les bienvenues !

1. Fork le projet
2. Crée ta branche (`git checkout -b feature/AmazingFeature`)
3. Commit tes changements (`git commit -m 'Add AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvre une Pull Request

---

## Licence

Ce projet est sous licence privée. Tous droits réservés.

---

<p align="center">
  <strong>Pockii</strong> - Ton budget, simplifié.<br/>
  Développé avec ❤️ pour la communauté FCFA.
</p>
