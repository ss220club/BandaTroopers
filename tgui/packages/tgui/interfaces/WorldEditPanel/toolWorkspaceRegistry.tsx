import type { ToolWorkspaceProps } from './types';
import { BlueprintStampWorkspace } from './workspaceBlueprint';
import { DestructionPackWorkspace } from './workspaceDestruction';
import { FortifyRoomWorkspace } from './workspaceFortify';
import { GenericToolWorkspace } from './workspaceGeneric';
import { OutpostRadiusWorkspace } from './workspaceOutpost';

type ToolWorkspaceRenderer = (props: ToolWorkspaceProps) => JSX.Element;

const TOOL_WORKSPACE_RENDERERS: Record<string, ToolWorkspaceRenderer> = {
  blueprint_stamp: ({ data, act }) => (
    <BlueprintStampWorkspace data={data} act={act} />
  ),
  fortify_room: ({ data, act }) => (
    <FortifyRoomWorkspace data={data} act={act} />
  ),
  outpost_radius: ({ data, act }) => (
    <OutpostRadiusWorkspace data={data} act={act} />
  ),
  destruction_pack: ({ data, act }) => (
    <DestructionPackWorkspace data={data} act={act} />
  ),
};

const renderToolWorkspace = (props: ToolWorkspaceProps) => {
  const renderer = props.data.current_generator_id
    ? TOOL_WORKSPACE_RENDERERS[props.data.current_generator_id]
    : undefined;

  if (renderer) {
    return renderer(props);
  }

  return (
    <GenericToolWorkspace
      data={props.data}
      act={props.act}
      groupedFields={props.groupedFields}
      groupNames={props.groupNames}
      showPlacementSetup={props.showPlacementSetup}
    />
  );
};

export { renderToolWorkspace };
