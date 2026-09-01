# Bounded Context — Gestion de campagne

## 1. Responsabilité

Le contexte **Gestion de campagne** est responsable de la composition et du cycle de vie d'une campagne de jeu de rôle.

Il connaît notamment :

- les campagnes ;
- les participants d'une campagne ;
- les animateurs d'une campagne ;
- les informations nécessaires pour contacter les participants/animateurs.

Il est la **source de vérité** pour déterminer qui participe à une campagne et qui l'anime.

---

## 2. Concepts métier

### Campagne

Une campagne possède :

- un **nom** ;
- un **jeu** ;
- au moins un **animateur** ;
- des **participants**.

Une campagne peut être supprimée par un animateur.

### Utilisateur

Un utilisateur existe indépendamment des campagnes.

Un même utilisateur peut participer à plusieurs campagnes.

Le fait de retirer un utilisateur d'une campagne ne supprime pas l'utilisateur de l'application.

### Participant

Un participant représente un utilisateur qui participe à une campagne.

Dans ce contexte, les informations utiles sont notamment :

```text
Participant
{
    id
    nom
    email
}
```

L'email est considéré comme une information applicable à toutes les campagnes auxquelles participe l'utilisateur.

### Animateur

Un animateur est un participant disposant des droits d'administration de la campagne.

Lorsqu'un utilisateur crée une campagne, il devient automatiquement :

- participant ;
- animateur.

---

## 3. Règles métier

### Création d'une campagne

Lorsqu'un utilisateur crée une campagne :

1. la campagne est créée avec son nom et son jeu ;
2. le créateur est ajouté comme participant ;
3. le créateur est ajouté comme animateur.

Une campagne doit toujours avoir au moins un animateur.

### Gestion des participants

Un animateur peut :

- ajouter un participant ;
- modifier les informations d'un participant ;
- retirer un participant.

Retirer un participant d'une campagne ne supprime pas son utilisateur.

Une modification des participants doit permettre d'alerter les animateurs de la campagne.

### Gestion des animateurs

Les animateurs sont responsables de la gestion de la campagne.

Une campagne doit conserver au moins un animateur.

### Suppression

Un animateur peut supprimer une campagne.

---

## 4. API / contrats exposés aux autres contextes

Les autres Bounded Contexts ne doivent pas utiliser directement les objets métier internes de Gestion de campagne.

Le contexte peut exposer une représentation simplifiée des participants :

```text
ParticipantDTO
{
    id
    nom
    email
}
```

Cette représentation constitue un **contrat externe**, et non le modèle métier interne à réutiliser dans les autres contextes.

### Pour Planification

Planification dépend de Gestion de campagne pour obtenir les participants d'une campagne lors de la création d'une date potentielle.

Flux conceptuel :

```text
Planification
    |
    | demander les participants
    v
Gestion de campagne
    |
    | ParticipantDTO { id, nom, email }
    v
Planification
    |
    | traduction via son ACL
    v
ParticipantPlanification
```

Le modèle interne de Planification doit rester indépendant du modèle de Gestion de campagne.

Si le modèle de Gestion de campagne évolue, Planification ne doit pas être obligée de modifier son modèle métier.

---

## 5. Interaction avec Notification

Notification dépend de Gestion de campagne pour déterminer les animateurs d'une campagne et récupérer leurs coordonnées.

Lorsqu'une date devient convenable :

```text
Planification
    |
    | DatePotentielleDevenueConvenable
    v
Notification
    |
    | Quels sont les animateurs ?
    v
Gestion de campagne
    |
    | Animateurs { id, nom, email }
    v
Notification
    |
    | envoyer la communication
    v
Email
```

Notification ne possède donc pas sa propre copie de la liste des animateurs ou de leurs emails.

Elle interroge Gestion de campagne lorsqu'elle en a besoin.

---

## 6. Frontière avec les autres Bounded Contexts

### Ce que Gestion de campagne possède

- l'identité des campagnes ;
- le nom et le jeu d'une campagne ;
- les participants ;
- les animateurs ;
- les informations de contact utilisées par les campagnes.

### Ce que Gestion de campagne ne possède pas

La planification d'une session n'appartient pas à ce contexte.

Gestion de campagne ne connaît pas :

- les dates potentielles ;
- les disponibilités ;
- la notion de date convenable ;
- le calcul de convenance d'une date ;
- l'envoi d'emails de notification.

Ces responsabilités appartiennent respectivement aux contextes **Planification** et **Notification**.

---

## 7. Features

### Campagnes

- [ ] Créer une campagne
- [ ] Supprimer une campagne

### Participants

- [ ] Ajouter un participant à une campagne
- [ ] Modifier un participant
- [ ] Retirer un participant d'une campagne

### Animateurs

- [ ] Ajouter un animateur
- [ ] Retirer un animateur
- [ ] Garantir qu'une campagne possède toujours au moins un animateur

### Notifications métier

- [ ] Signaler une modification de la liste des participants afin que les animateurs puissent être alertés

---

## 8. Points d'attention DDD

### Ne pas partager les agrégats

Les autres contextes ne doivent pas manipuler directement les agrégats de Gestion de campagne.

Ils utilisent des contrats adaptés à leurs besoins.

### Le participant n'est pas nécessairement le même concept partout

Dans Planification, le participant est transformé en un objet propre au contexte de planification.

Par exemple :

```text
Gestion de campagne
    Participant
        id
        nom
        email

        |
        | ACL
        v

Planification
    ParticipantPlanification
        participantId
        nom
```

Les deux modèles peuvent évoluer indépendamment.

### Email

L'email est stocké dans ce contexte pour les besoins des campagnes et des communications.

Un changement d'email doit être considéré comme applicable à toutes les campagnes auxquelles participe l'utilisateur.

---

## 9. Décisions métier actuelles

| Sujet | Décision |
|---|---|
| Un utilisateur peut participer à plusieurs campagnes | Oui |
| Un utilisateur peut exister sans participer à une campagne | Oui |
| Le créateur devient participant | Oui |
| Le créateur devient animateur | Oui |
| Une campagne doit avoir un animateur | Oui, au moins un |
| Un animateur peut gérer les participants | Oui |
| Un animateur peut supprimer la campagne | Oui |
| Retirer un participant supprime l'utilisateur | Non |
| L'email est utilisable pour toutes les campagnes | Oui |
| Planification utilise directement le modèle Participant | Non |
| Planification possède son propre modèle | Oui |
| Notification récupère les animateurs auprès de Gestion de campagne | Oui |
