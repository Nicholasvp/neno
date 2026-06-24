class MedicalReference {
  final String title;
  final String source;
  final String url;

  const MedicalReference({
    required this.title,
    required this.source,
    required this.url,
  });
}

class References {
  References._();

  static const list = [
    MedicalReference(
      title: 'Ácido fólico na gestação',
      source: 'World Health Organization (WHO)',
      url: 'https://www.who.int/tools/elena/intervention/folic-acid-periconceptional',
    ),
    MedicalReference(
      title: 'Movimentação fetal — contagem',
      source: 'American College of Obstetricians and Gynecologists (ACOG)',
      url: 'https://www.acog.org/clinical/clinical-guidance/committee-opinion/articles/2021/03/physical-activity-and-exercise-during-pregnancy-and-the-postpartum-period',
    ),
    MedicalReference(
      title: 'Ultrassonografia morfológica',
      source: 'World Health Organization (WHO)',
      url: 'https://www.who.int/publications/i/item/9789241549912',
    ),
    MedicalReference(
      title: 'Cuidados pré-natais',
      source: 'Ministério da Saúde — Brasil',
      url: 'https://www.gov.br/saude/pt-br/assuntos/saude-de-a-a-z/g/gestante',
    ),
    MedicalReference(
      title: 'Queda na movimentação fetal — conduta',
      source: 'Federação Brasileira de Ginecologia e Obstetrícia (FEBRASGO)',
      url: 'https://www.febrasgo.org.br/pt/noticias/item/1380-atencao-a-diminuicao-da-movimentacao-fetal',
    ),
    MedicalReference(
      title: 'Plano de parto',
      source: 'World Health Organization (WHO)',
      url: 'https://www.who.int/reproductivehealth/publications/maternal_perinatal_health/WHO-RHR-15.02/en/',
    ),
    MedicalReference(
      title: 'Amamentação e puerpério',
      source: 'Ministério da Saúde — Brasil',
      url: 'https://bvsms.saude.gov.br/bvs/publicacoes/saude_crianca_aleitamento_materno.pdf',
    ),
    MedicalReference(
      title: 'Atividade física na gestação',
      source: 'American College of Obstetricians and Gynecologists (ACOG)',
      url: 'https://www.acog.org/clinical/clinical-guidance/committee-opinion/articles/2020/04/physical-activity-and-exercise-during-pregnancy-and-the-postpartum-period',
    ),
  ];
}
