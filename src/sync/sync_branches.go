package sync

import (
	"github.com/git-town/git-town/v14/src/cmd/cmdhelpers"
	"github.com/git-town/git-town/v14/src/git/gitdomain"
	. "github.com/git-town/git-town/v14/src/gohacks/prelude"
	"github.com/git-town/git-town/v14/src/vm/opcodes"
)

// BranchesProgram syncs all given branches.
func BranchesProgram(args BranchesProgramArgs) {
	for _, branch := range args.BranchesToSync {
		BranchProgram(branch, args.BranchProgramArgs)
	}
	previousbranchCandidates := gitdomain.LocalBranchNames{}
	finalBranchCandidates := gitdomain.LocalBranchNames{args.InitialBranch}
	if previousBranch, hasPreviousBranch := args.PreviousBranch.Get(); hasPreviousBranch {
		finalBranchCandidates = append(finalBranchCandidates, previousBranch)
		previousbranchCandidates = append(previousbranchCandidates, previousBranch)
	}
	args.Program.Add(&opcodes.CheckoutFirstExisting{
		Branches:   finalBranchCandidates,
		MainBranch: args.Config.MainBranch,
	})
	if args.Remotes.HasOrigin() && args.ShouldPushTags && args.Config.IsOnline() {
		args.Program.Add(&opcodes.PushTags{})
	}
	cmdhelpers.Wrap(args.Program, cmdhelpers.WrapOptions{
		DryRun:           args.DryRun,
		RunInGitRoot:     true,
		StashOpenChanges: args.HasOpenChanges,
		PreviousBranch:   previousbranchCandidates,
	})
}

type BranchesProgramArgs struct {
	BranchProgramArgs
	BranchesToSync gitdomain.BranchInfos
	DryRun         bool
	HasOpenChanges bool
	InitialBranch  gitdomain.LocalBranchName
	PreviousBranch Option[gitdomain.LocalBranchName]
	ShouldPushTags bool
}
