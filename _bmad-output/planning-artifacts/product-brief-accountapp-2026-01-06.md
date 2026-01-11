---
stepsCompleted: [1, 2, 3, 4, 5, 6]
status: complete
completedAt: 2026-01-06
inputDocuments:
  - _bmad-output/analysis/brainstorming-session-2026-01-06.md
date: 2026-01-06
author: Wilfriedhouinlindjonon
project_name: accountapp
---

# Product Brief: accountapp

## Executive Summary

accountapp est une application mobile de gestion financière personnelle conçue pour les personnes à revenus modestes, avec une attention particulière au contexte africain. L'application transforme la gestion budgétaire passive (tableaux, calculs mentaux) en un système intelligent centré sur deux concepts clés :

1. **"Reste à vivre"** — savoir exactement combien on peut dépenser aujourd'hui
2. **"Tes Patterns"** — révéler les habitudes de dépenses invisibles pour passer du mode réactif au mode proactif

L'objectif : briser le cycle des dettes mensuelles (emprunts aux proches, remboursements le mois suivant) et guider les utilisateurs vers la tranquillité financière — un parcours progressif allant de la survie mensuelle → contrôle de son argent → épargne → investissement → gestion familiale.

**Cause racine adressée :** Les utilisateurs n'ont jamais VU leurs propres patterns de dépenses. Sans cette visibilité historique, ils ne peuvent pas anticiper et restent en mode réactif permanent.

**Principes de conception :**
- Onboarding minimaliste (3 écrans max)
- Fonctionnalités débloquées progressivement
- Ton bienveillant jamais culpabilisant
- UN chiffre central : "Reste à vivre"
- Révélation progressive des patterns personnels

---

## Core Vision

### Problem Statement

Les personnes à revenus modestes en Afrique manquent d'outils intelligents pour gérer leurs finances au quotidien. Ils utilisent des solutions passives (tableaux Notion, calculs mentaux) qui ne fournissent ni alertes, ni analyses, ni conseils. Résultat : un cycle de dettes où ils empruntent à leurs proches en fin de mois et remboursent le mois suivant, sans jamais progresser vers l'épargne ou l'investissement.

**Vérité fondamentale :** Le problème n'est pas l'ignorance — les gens SAVENT qu'ils dépensent trop. Le problème est la VISIBILITÉ en temps réel et l'EXÉCUTION.

**Cause racine (5 Whys) :** Les utilisateurs n'ont jamais vu leurs propres patterns de dépenses visualisés. Sans historique, ils ne peuvent pas anticiper les obligations récurrentes et restent en mode réactif permanent.

### Problem Impact

- **Court terme** : Stress financier constant, surprises en fin de mois, dépenses impulsives non détectées
- **Moyen terme** : Dépendance aux proches, relations familiales tendues par les emprunts répétés
- **Long terme** : Impossibilité d'épargner, d'investir, ou de planifier (mariage, famille, carrière)

**Impact des obligations culturelles :**
- Pression sociale à donner à la famille (surtout au premier salaire)
- Cotisations et événements sociaux non planifiés (mariages, baptêmes, décès)
- Difficulté à dire "non" sans outils pour justifier ses limites budgétaires

**Cycle vicieux identifié :**
```
Pas de visibilité sur patterns → Pas d'anticipation → Mode réactif →
Dépenses > Revenus → Emprunt aux proches → Remboursement mois suivant →
Budget réduit → Cycle recommence
```

### Why Existing Solutions Fall Short

Les applications financières existantes (Bankin', YNAB, Mint) :
- Ne prennent pas en compte la culture financière africaine (tontines, cotisations, obligations familiales)
- Sont conçues pour des contextes occidentaux (comptes bancaires multiples, cartes de crédit)
- Manquent de personnalisation pour les revenus modestes et les réalités locales (FCFA, paiements cash)
- Sont réactives (constatent après) plutôt que préventives (alertent avant)
- Affichent trop d'informations — dashboards complexes au lieu d'un chiffre actionnable
- **Ne révèlent pas les patterns personnels** — pas de "aha moments" de prise de conscience

### Proposed Solution

**Concepts centraux :**
- **"Reste à vivre"** : L'écran principal affiche UN SEUL CHIFFRE — combien l'utilisateur peut dépenser aujourd'hui
- **"Tes Patterns"** : Après 1 mois, l'app révèle les habitudes invisibles pour permettre l'anticipation

accountapp analyse les données financières de l'utilisateur et fournit :

**MVP (Analyse, Visibilité & Patterns) :**
- **Import automatique SMS** : Lecture des confirmations Mobile Money (Orange Money, Wave, MTN) pour catégorisation automatique
- **"Reste à vivre" en temps réel** : Un chiffre central, actualisé à chaque transaction
- **"Tes Patterns" (après 1 mois)** : Révélation des habitudes de dépenses par catégorie
  - "Transport : 47,000 FCFA/mois en moyenne"
  - "Food dehors : 32,000 FCFA/mois"
  - "Cotisations sociales : ~25,000 FCFA tous les 2 mois"
- **Alertes préventives basées sur TES patterns** :
  - "Tu as déjà dépensé 35,000 en transport cette semaine — 50% de plus que d'habitude"
  - "Dernier mois, tu as dépensé 15,000 le weekend — tu veux fixer un budget weekend ?"
- **"Aha Moments"** : Notifications mensuelles de prise de conscience
  - "Ce mois tu as économisé 12,000 sur le transport vs le mois dernier"
  - "Si tu maintiens ce rythme, tu auras 150,000 d'épargne dans 6 mois"
- **Suivi des cotisations** : Gestion des tontines, abonnements annuels, obligations familiales
- **Saisie vocale rapide** : "J'ai dépensé 2000 en taxi" pour les transactions cash

**Post-MVP (Anticipation, Contrôle & Croissance) :**
- **"Prévisions du mois"** : En début de mois, l'app prédit les dépenses probables
  - "Basé sur tes habitudes, tu vas probablement dépenser 280,000 FCFA ce mois"
  - "Attention : Janvier = mois des cotisations de rentrée"
- **Cercles d'épargne** : Groupes de 5 personnes qui s'encouragent et se challengent mutuellement
- **Coffre-fort virtuel** : Visualisation de l'épargne "intouchable" (sans blocage réel)
- **Épargne calculée** : Suggestions personnalisées basées sur les patterns réels
- **Parcours progressif** : Accompagnement adapté au niveau (survie → contrôle → épargne → investissement)
- **Module investissement** : Introduction simple aux ETF, Bitcoin (partenariats futurs)

### Key Differentiators

1. **"Reste à vivre" comme concept central** : Un chiffre, pas un dashboard — simplicité radicale
2. **"Tes Patterns" révélés** : Première app qui montre aux utilisateurs leurs habitudes invisibles
3. **Import automatique SMS Mobile Money** : Zéro saisie manuelle pour 80% des transactions
4. **Alertes basées sur patterns personnels** : Pas génériques, mais contextuelles à TES habitudes
5. **"Aha Moments"** : Notifications de prise de conscience qui créent le déclic
6. **Prévisions mensuelles** : Anticiper au lieu de subir (post-MVP)
7. **Culture africaine intégrée** : Tontines, cotisations familiales, obligations sociales, contexte FCFA
8. **Cercles d'épargne** : Dimension sociale/communautaire pour motivation durable
9. **Approche bienveillante** : Coach financier qui motive, jamais culpabilisant

---

## Risks & Mitigations

### Risques identifiés (Pre-mortem Analysis)

| Risque | Probabilité | Impact | Stratégie de mitigation |
|--------|-------------|--------|-------------------------|
| **App trop compliquée** | Élevée | Fatal | Onboarding 3 écrans max, "Reste à vivre" comme focus unique |
| **Utilisateurs n'entrent pas leurs données** | Très élevée | Fatal | Import SMS Mobile Money automatique, saisie vocale |
| **Alertes perçues comme agaçantes** | Moyenne | Élevé | Basées sur patterns personnels, max 2/jour, ton bienveillant |
| **Pas de modèle de revenus viable** | Élevée | Fatal | Définir business model (freemium, partenariats, commissions) |
| **Concurrence des wallets (Wave, Orange Money)** | Moyenne | Élevé | "Tes Patterns", communauté, features uniques (tontines) |
| **Pas assez de données pour patterns** | Moyenne | Élevé | Valeur immédiate avec "Reste à vivre" dès J1, patterns débloqués à M+1 |

### Vérités fondamentales (First Principles)

| Vérité | Implication pour accountapp |
|--------|----------------------------|
| Les gens SAVENT qu'ils dépensent trop | Focus sur VISIBILITÉ et EXÉCUTION, pas éducation |
| La valeur doit être immédiate | "Reste à vivre" visible dès la 1ère transaction |
| La simplicité bat les fonctionnalités | 1 écran, 1 chiffre pour le MVP |
| Le social influence plus que le rationnel | Cercles d'épargne post-MVP |
| Le mobile money EST le compte bancaire | Import SMS comme feature core |
| **Les gens n'ont jamais VU leurs patterns** | "Tes Patterns" comme révélation clé à M+1 |

### Chaîne causale (5 Whys)

```
Empruntent en fin de mois
        ↓ WHY?
Dépenses > Revenus
        ↓ WHY?
Pas de visibilité temps réel
        ↓ WHY?
Transactions fragmentées + obligations non planifiées
        ↓ WHY?
Pas d'historique pour prévoir les patterns
        ↓ WHY?
═══════════════════════════════════════════════════
CAUSE RACINE : N'ont jamais VU leurs propres patterns
═══════════════════════════════════════════════════
        ↓ SOLUTION ACCOUNTAPP
Révèle les patterns → permet l'anticipation →
active le mode PROACTIF → fin du cycle de dettes
```

### Questions ouvertes à résoudre

- [ ] **Business Model** : Freemium ? Partenariats bancaires ? Commissions sur investissements ?
- [ ] **Lecture SMS** : Permissions Android/iOS ? Parsing des formats Orange Money/Wave/MTN ?
- [ ] **Marché initial** : Un seul pays d'abord (Côte d'Ivoire, Sénégal) ou multi-pays ?
- [ ] **Réglementation** : Contraintes légales sur la lecture des SMS financiers ?
- [ ] **Délai patterns** : 1 mois suffisant pour révéler des patterns utiles ?

---

## Target Users

### Primary User: Le Dev Full Stack Africain (Persona principal)

**Profil type : Wilfried, 27 ans, Développeur Full Stack**

- **Contexte :** Salaire 350k FCFA, loyer 100k FCFA, célibataire avec copine
- **Situation :** Revenu stable mais gestion chaotique, finit souvent le mois en empruntant aux proches
- **Gestion actuelle :** Argent en cash (main propre), tableau Notion basique, ne check jamais son solde Mobile Money
- **Pain points :**
  - Dépenses "pirates" : taxi imprévu, weekends famille, demandes copine, cotisations surprise
  - Réalise le problème seulement en fin de mois
  - Cycle : emprunt → remboursement → budget réduit → emprunt

**Dépenses quotidiennes :**
- Lun-Ven : petit-déj (150-300) + transport (200) + déjeuner (1000) = ~1,350-1,500 FCFA/jour
- Dimanche : église ~1,500 FCFA
- Samedi : variable (sorties, famille)
- Base mensuelle : ~35,000-50,000 FCFA (hors loyer, factures, imprévus)

**Répartition des canaux :**
- Mobile Money (30-40%) : loyer, factures, abonnements → dépenses fixes, prévisibles
- Cash (60-70%) : quotidien, sorties, imprévus → dépenses variables, "pirates"

**Définition du succès :** Finir le mois sans emprunter, et idéalement avoir épargné

**Ce qui le ferait dire "wow" :** Voir ses patterns de dépenses révélés pour la première fois, comprendre où part son argent

---

### Secondary Users: Évolutions du même persona

**Le parcours utilisateur est une évolution temporelle :**

**Stade 1 : L'Étudiant Fauché (Wilfried avant)**
- Pas de revenu stable, dépendance aux parents
- Micro-dépenses invisibles, psychologie du "billet cassé"
- Besoin : Survie, visibilité basique, pas de culpabilisation

**Stade 2 : Le Jeune Actif Premier Job (Wilfried il y a 3 ans)**
- Premier salaire, nouvelles responsabilités (donner à la famille)
- Le mindset ne scale pas avec le salaire
- Besoin : Éducation financière progressive, gestion des obligations familiales

**Stade 3 : Le Dev Établi (Wilfried maintenant)** ← Persona prioritaire MVP
- Revenu stable mais gestion chaotique
- Dépenses sociales et relationnelles importantes
- Besoin : Visibilité patterns, alertes préventives, "Reste à vivre"

**Stade 4 : Le Futur Wilfried (objectif)**
- Capacité d'investir, gestion familiale
- Épargne automatique, objectifs long terme
- Besoin : Modules investissement, gestion multi-personnes

---

### User Journey

**Découverte :**
- Pub sur réseaux sociaux (Instagram, TikTok, Facebook)
- Recommandation d'un ami qui a réussi à épargner

**Onboarding (3 écrans max) :**
1. "Quel est ton salaire mensuel ?" → 350,000 FCFA
2. "Quelles sont tes dépenses fixes ?" → Loyer 100k, factures ~20k
3. "C'est parti !" → Affichage immédiat du "Reste à vivre"

**Première semaine :**
- Import automatique SMS des transactions Mobile Money (loyer, factures)
- Saisie vocale des dépenses cash : "J'ai dépensé 1000 en déjeuner"
- Découverte du "Reste à vivre" qui se met à jour

**Premier mois :**
- Fin de mois : Notification "Tu as fini le mois sans emprunter !" ou alerte précoce si danger
- Déblocage de "Tes Patterns" : révélation des habitudes

**Moment "Aha!" :**
- "Tu dépenses 45,000 FCFA/mois en transport — 15% de plus que ta moyenne"
- "Tes weekends famille te coûtent ~30,000 FCFA/mois"
- Première prise de conscience des patterns invisibles

**Long terme :**
- Utilisation quotidienne du "Reste à vivre" avant chaque dépense
- Alertes personnalisées : "Tu as déjà dépensé ton budget taxi de la semaine"
- Progression vers l'épargne puis l'investissement

---

## Success Metrics

### User Success Metrics

**Définition du succès utilisateur :** L'utilisateur termine le mois avec un solde positif (Revenus - Dépenses > 0)

**Aha Moments progressifs :**

| Moment | Timing | Déclencheur |
|--------|--------|-------------|
| **Aha #1** | 24h | "Reste à vivre" se met à jour après 1ère saisie |
| **Aha #2** | 7 jours | Badge "7-Day Streak" débloqué |
| **Aha #3** | 1 mois | Révélation "Tes Patterns" |

**Comportements clés à tracker :**
- Saisie de dépense (objectif : 1×/jour minimum)
- Consultation du "Reste à vivre" (objectif : 1×/jour)
- Complétion des streaks de 7 jours

---

### Business Objectives

**Objectifs à 3 mois :**
- Focus : **Acquisition + Validation PMF**
- Cible : 1,000+ utilisateurs actifs mensuels (MAU)
- Validation : M1 Retention > 30%

**Objectifs à 12 mois :**
- Focus : **Rétention + Monétisation**
- Cible : 10,000+ MAU avec M3 Retention > 20%
- Premiers revenus via modèle freemium ou partenariats

**Stratégie de monétisation :**
- Phase 1 (MVP) : 100% gratuit — focus acquisition
- Phase 2 : Freemium (features premium : export, multi-comptes, historique)
- Phase 3 : Partenariats Mobile Money, affiliation investissement

---

### Key Performance Indicators (KPIs)

**3 KPIs managés activement (MVP) :**

| KPI | Description | Cible | Type |
|-----|-------------|-------|------|
| **7-Day Streak Rate** | % d'utilisateurs avec 7 jours consécutifs de saisie | > 40% | Leading indicator |
| **M1 Retention** | % d'utilisateurs actifs à M+1 | > 30% | Core metric |
| **Implicit Save Rate** | % avec (Revenus - Dépenses saisies) > 0 à fin de mois | > 25% | North Star |

**KPIs trackés passivement :**

| Catégorie | KPI | Cible |
|-----------|-----|-------|
| **Acquisition** | Activation Rate (onboarding complété) | > 60% |
| **Acquisition** | First Transaction within 24h | > 70% |
| **Engagement** | DAU/MAU Ratio | > 30% |
| **Engagement** | Transactions/User/Week | > 10 |
| **Rétention** | D1 Retention | > 50% |
| **Rétention** | D7 Retention | > 35% |

**North Star Metric :**

> **"Implicit Save Rate"** — Le % d'utilisateurs dont (Revenus - Dépenses saisies) > 0 à fin de mois
>
> Mesure objective sans friction : si l'utilisateur a saisi toutes ses dépenses et qu'il reste de l'argent, il a "épargné".
> Cette métrique capture la valeur fondamentale : transformer le cycle de dettes en cycle d'épargne.

---

## MVP Scope

### Core Features (MVP 1 mois)

**1. "Reste à vivre" en temps réel**
- Écran principal avec UN chiffre : montant disponible aujourd'hui
- Calcul : (Revenus du mois) - (Dépenses fixes) - (Dépenses saisies) = Reste à vivre
- Mise à jour instantanée après chaque saisie
- Code couleur : Vert (OK) / Orange (Attention) / Rouge (Danger)

**2. Saisie manuelle des dépenses**
- Interface simple : Montant + Catégorie + Note (optionnel)
- Catégories prédéfinies : Transport, Nourriture, Loisirs, Famille, Cotisations, Autre
- Historique des dépenses consultable
- Modification/suppression possible

**3. "Tes Patterns" (après 1 mois)**
- Déblocage automatique après 30 jours de données
- Affichage des moyennes par catégorie
- Comparaison avec le mois précédent (si disponible)
- Top 3 des catégories de dépenses

**4. Suivi des cotisations**
- Liste des cotisations récurrentes (tontines, abonnements, obligations)
- Rappels avant échéance
- Montant total des cotisations du mois
- Intégration dans le calcul du "Reste à vivre"

---

### Out of Scope for MVP

**Reporté à v1.1 (après validation MVP) :**
- Import automatique SMS Mobile Money (nécessite parsing robuste)
- Alertes préventives avancées (basées sur patterns)

**Reporté à v2.0+ :**
- Saisie vocale (complexité technique)
- Prévisions mensuelles
- Cercles d'épargne (communauté)
- Coffre-fort virtuel
- Module investissement
- Multi-comptes / Gestion familiale

**Explicitement exclus du MVP :**
- Connexion aux APIs bancaires
- Synchronisation cloud entre appareils
- Version web (mobile-first uniquement)
- Monétisation (100% gratuit pour MVP)

---

### MVP Success Criteria

**Critères de validation (après 1 mois de beta) :**

| Critère | Cible | Méthode de mesure |
|---------|-------|-------------------|
| **Utilisateurs beta actifs** | 5-10 personnes | Comptage manuel |
| **7-Day Streak Rate** | > 50% des beta testeurs | Analytics app |
| **Feedback qualitatif** | "Utile" ou "Très utile" | Interviews |
| **Bugs critiques** | 0 bloquants | Bug reports |

**Go/No-Go pour v1.1 :**
- GO si : >50% des beta testeurs utilisent l'app quotidiennement après 2 semaines
- NO-GO si : Abandon massif avant 7 jours ou feedback négatif majoritaire

**Questions à valider avec la beta :**
- Le "Reste à vivre" est-il consulté quotidiennement ?
- La saisie manuelle est-elle trop contraignante ?
- Les patterns créent-ils un "Aha moment" ?
- L'import SMS est-il vraiment nécessaire ?

---

### Future Vision

**Court terme (v1.1 - M+2) :**
- Import SMS Mobile Money (Orange Money, Wave)
- Alertes préventives basées sur patterns
- Amélioration UX basée sur feedback beta

**Moyen terme (v2.0 - M+6) :**
- Saisie vocale
- Prévisions mensuelles
- Cercles d'épargne (communauté)
- Gamification avancée (badges, niveaux)

**Long terme (v3.0 - M+12) :**
- Module investissement (partenariats ETF, crypto)
- Gestion familiale multi-utilisateurs
- Partenariats Mobile Money pour import automatique
- Expansion régionale (autres pays FCFA)

**Vision 3 ans :**
> accountapp devient LA référence de gestion financière personnelle en Afrique francophone, accompagnant les utilisateurs de leur premier budget étudiant jusqu'à la gestion de leur patrimoine familial.
