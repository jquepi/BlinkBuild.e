
import ArgumentParser
import Foundation
import Machines
import NonStdIO


public struct ImageCommands: NonStdIOCommand {
  public init() {}
  
  public static var configuration = CommandConfiguration(
    commandName: "image",
    abstract: "Commands working with containers. Default is build",
    subcommands: [customImageBuildCommand ?? Build.self, LS.self],
    defaultSubcommand: customImageBuildCommand ?? Build.self
  )
  
  public static var customImageBuildCommand: ParsableCommand.Type? = nil
  
  @OptionGroup public var verboseOptions: VerboseOptions
  public var io = NonStdIO.standart
  
  struct Build: NonStdIOCommand {
    static var configuration = CommandConfiguration(
      commandName: "build",
      abstract: "Build images",
      subcommands: [LS.self]
    )
    
    @OptionGroup var verboseOptions: VerboseOptions
    var io = NonStdIO.standart
  
    @Option(
      name: .shortAndLong,
      help: "Name and optionally a tag in the 'name:tag' format"
    )
    var tag: String = ""
    
    @Argument(
      help: "git url"
    )
    var gitURL: String
    
    func validate() throws {
      guard let _ = URL(string: gitURL)
      else {
        throw ValidationError("Invalid git url")
      }
    }
    
    func run() throws {
      let ip = try machine().ip().awaitOutput()!
      let user = BuildCLIConfig.shared.sshUser
      let args = ["", "-c", "ssh -t -A \(verboseOptions.verbose ? "-v" : "") \(user)@\(ip) build-ctl \([tag, gitURL].filter { $0.isEmpty }.joined(separator: " "))"]
      
      printDebug("Executing command \"/bin/sh" + args.joined(separator: " ") + "\"")
      
      let cargs = args.map { strdup($0) } + [nil]
      
      execv("/bin/sh", cargs)
      
      fatalError("exec failed")
    }
  }
  
  struct LS: NonStdIOCommand {
    static var configuration = CommandConfiguration(
      abstract: "List images"
    )
    
    @OptionGroup var verboseOptions: VerboseOptions
    var io = NonStdIO.standart
    
    func run() throws {
      print("Not implemented yet")
    }
  }
}
