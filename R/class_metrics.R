#' classification metrics
#'
#' @param ml machine learning algorithm fitted.
#' @param train train dataset preprocessed.
#' @param ml_title title of the machine learning algorithm.
#'
#' @returns A gt object containing the ranking metrics table for the train data and test data.
#' @export
#'
#' @examples 1+1
class_metrics <- function(ml, train, ml_title){
    table <- dplyr::bind_cols(train %>%
                                  predict(ml, new_data = . ) |>
                                  dplyr::mutate(Real= train$class) |>
                                  yardstick::conf_mat(truth = Real,
                                                      estimate = .pred_class ) |>
                                  summary() |>
                                  dplyr::rename(train = .estimate),
                              test %>%
                                  predict(ml, new_data = . ) |>
                                  dplyr::mutate(Real= test$class) |>
                                  yardstick::conf_mat(truth = Real,
                                                      estimate = .pred_class ) |>
                                  summary() |>
                                  dplyr::rename(test = .estimate) |>
                                  dplyr::select(test)) |>
        dplyr::mutate(difference = train-test) |>
        dplyr::mutate(train = round(train, 2),
                      test = round(test, 2),
                      difference = round(difference, 2))

    tss <- table |>
        dplyr::filter(.metric %in% c("sens", "spec"))


    y <- train %>%
        predict(ml, new_data = ., type = "prob") |>
        dplyr::mutate(Real= train$class) |>
        dplyr::mutate(Real = ifelse(Real == "presence", 1, 0))

    x  <- test %>%
        predict(ml, new_data = ., type = "prob") |>
        dplyr::mutate(Real= test$class) |>
        dplyr::mutate(Real = ifelse(Real == "presence", 1, 0)) |>
        dplyr::select(-.pred_pseudoabs)

    table |>
        dplyr::bind_rows(tibble::tibble(.metric = c("auc"),
                                        .estimator = c("binary"),
                                        train = round(Metrics::auc(y$Real, y$.pred_presence),2),
                                        test = round(Metrics::auc(x$Real, x$.pred_presence),2),
                                        difference = round(train-test, 2)),
                         tibble::tibble(.metric = c("TSS"),
                                        .estimator = c("binary"),
                                        train = sum(tss$train)-1,
                                        test = sum(tss$test)-1,
                                        difference = round(train-test, 2))) |>
        #dplyr::arrange(dplyr::desc(train)) |>
        gt::gt() |>
        gt::tab_header(title = ml_title) |>
        gt::tab_style(style = list(gt::cell_text(weight = "bold")),
                      locations = gt::cells_body(columns = c(.metric, train, test, difference),
                                                 rows = .metric %in% c("auc","TSS", "sens",
                                                                       "accuracy", "bal_accuracy")))
}
