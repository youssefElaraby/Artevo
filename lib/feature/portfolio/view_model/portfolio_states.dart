import 'package:art_by_hager_ismail/feature/portfolio/model/portfolio_model.dart' show ProfileModel, StatCardModel, ServiceModel, SkillModel, ArtworkModel;

abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioSuccess extends PortfolioState {
  final ProfileModel profile;
  final List<StatCardModel> stats;
  final List<ServiceModel> services;
  final List<SkillModel> skills;
  final List<ArtworkModel> artworks;

  PortfolioSuccess({
    required this.profile,
    required this.stats,
    required this.services,
    required this.skills,
    required this.artworks,
  });
}

class PortfolioError extends PortfolioState {
  final String error;
  PortfolioError(this.error);
}