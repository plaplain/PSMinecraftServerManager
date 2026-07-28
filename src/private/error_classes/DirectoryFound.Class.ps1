class DirectoryFound : System.Exception {
    hidden $BaseErrorMessage = 'The directory exists when not expected to'

    DirectoryFound() : base("$BaseErrorMessage.") {}

    DirectoryFound([string]$DirectoryPath) : base("$BaseErrorMessage '$DirectoryPath'.") {}

    DirectoryFound([string]$DirectoryPath, [System.Exception]$InnerExceptionMessage) : base(
        "$BaseErrorMessage '$DirectoryPath'.",
        $InnerExceptionMessage) {
    }
}
