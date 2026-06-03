#' classification metrics
#'
#' @param ml machine learning algorithm fitted.
#' @param train train dataset preprocessed.
#' @param test test dataset preprocessed.
#' @param ml_title title of the machine learning algorithm.
#'
#' @returns A gt object containing the ranking metrics table for the train data and test data.
#' @export
#'
#' @examples 1+1
class_metrics <- function(ml, train, test, ml_title){
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


    y_binary <- train %>%
        predict(ml, new_data = ., type = "prob") |>
        dplyr::mutate(Real= train$class) |>
        dplyr::mutate(Real = ifelse(Real == "presence", 1, 0))

    x_binary  <- test %>%
        predict(ml, new_data = ., type = "prob") |>
        dplyr::mutate(Real= test$class) |>
        dplyr::mutate(Real = ifelse(Real == "presence", 1, 0)) |>
        dplyr::select(-.pred_pseudoabs)

    y_class <- train %>%
        predict(ml, new_data = ., type = "prob") |>
        dplyr::mutate(Real= train$class)

    x_class  <- test %>%
        predict(ml, new_data = ., type = "prob") |>
        dplyr::mutate(Real= test$class) |>
        dplyr::select(-.pred_pseudoabs)

    table |>
        dplyr::bind_rows(tibble::tibble(.metric = c("auc"),
                                        .estimator = c("binary"),
                                        train = round(Metrics::auc(y_binary$Real, y_binary$.pred_presence),2),
                                        test = round(Metrics::auc(x_binary$Real, x_binary$.pred_presence),2),
                                        difference = round(train-test, 2)),
                         tibble::tibble(.metric = c("BCI"),
                                        .estimator = c("binary"),
                                        train = round(tidysdm::boyce_cont_vec(y_class$Real, y_class$.pred_presence),2),
                                        test = round(tidysdm::boyce_cont_vec(x_class$Real, x_class$.pred_presence),2),
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
                                                                       "accuracy", "bal_accuracy", "BCI")))

}
