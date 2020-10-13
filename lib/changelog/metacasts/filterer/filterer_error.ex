defmodule Changelog.Metacasts.Filterer.FiltererError do
    alias Changelog.Metacasts.Filterer.FiltererError
    defexception [:message]


    @impl true
    def exception({:result_error, error}) do
        %FiltererError{message: "An error occurred during filtering: #{inspect(error)}"}
    end

    @impl true
    def exception({:bad_statement, statement}) do
        %FiltererError{message: "A bad statement was encountered during filter generation: #{inspect(statement)}"}
    end

    @impl true
    def exception({:bad_nesting, message}) do
        %FiltererError{message: message}
    end

    @impl true
    def exception(_) do
        %FiltererError{message: "A generic error occured. Weird."}
    end
end