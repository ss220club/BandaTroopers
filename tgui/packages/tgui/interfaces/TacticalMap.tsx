import { useEffect, useRef, useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { ByondUi } from '../components';
import { Window } from '../layouts';
import { CanvasLayer } from './CanvasLayer';
import { DrawnMap } from './DrawnMap';

interface TacMapProps {
  toolbarColorSelection: string;
  toolbarUpdatedSelection: string;
  updatedCanvas: boolean;
  themeId: number;
  svgData: any;
  canViewTacmap: boolean;
  canDraw: boolean;
  isxeno: boolean;
  canViewCanvas: boolean;
  newCanvasFlatImage: string;
  oldCanvasFlatImage: string;
  actionQueueChange: number;
  exportedColor: string;
  mapFallback: string;
  mapRef: string;
  mapZoom: number;
  mapPanX: number;
  mapPanY: number;
  currentMenu: string;
  lastUpdateTime: any;
  canvasCooldownDuration: any;
  canvasCooldown: any;
  exportedTacMapImage: any;
  tacmapReady: boolean;
}

const PAGES = [
  {
    title: 'Live Tacmap',
    canOpen: (data: TacMapProps) => {
      return true;
    },
    component: () => ViewMapPanel,
    icon: 'map',
    canAccess: (data: TacMapProps) => {
      return data.canViewTacmap;
    },
  },
  {
    title: 'Map View',
    canOpen: (data: TacMapProps) => {
      return true;
    },
    component: () => OldMapPanel,
    icon: 'eye',
    canAccess: (data: TacMapProps) => {
      return data.canViewCanvas;
    },
  },
  {
    title: 'Canvas',
    canOpen: (data: TacMapProps) => {
      return data.tacmapReady;
    },
    component: () => DrawMapPanel,
    icon: 'paintbrush',
    canAccess: (data: TacMapProps) => {
      return data.canDraw;
    },
  },
];

// DemonicLynx for BandaMarines - START: zoomed tactical Canvas viewport
const TACTICAL_CANVAS_SIZE = 684;
const TACTICAL_CANVAS_ZOOM = 2;
// DemonicLynx for BandaMarines - END

const colorOptions = [
  'black',
  'red',
  'orange',
  'blue',
  'purple',
  'green',
  'brown',
];

const colors: Record<string, string> = {
  black: '#000000',
  red: '#fc0000',
  orange: '#f59a07',
  blue: '#0561f5',
  purple: '#c002fa',
  green: '#02c245',
  brown: '#5c351e',
};

export const TacticalMap = (props) => {
  const { data, act } = useBackend<TacMapProps>();
  const [pageIndex, setPageIndex] = useState(data.canViewTacmap ? 0 : 1);
  const PageComponent = PAGES[pageIndex].component();

  const handleTacmapOnClick = (i: number, pageTitle: string) => {
    setPageIndex(i);
    act('menuSelect', {
      selection: pageTitle,
    });
  };

  // DemonicLynx for BandaMarines: wider tactical map viewport
  return (
    <Window
      width={900}
      height={800}
      theme={data.isxeno ? 'hive_status' : 'crtblue'}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              fitted
              width="100%"
              fontSize="20px"
              textAlign="center"
              title="Tactical Map Options"
            >
              <Stack fontSize="15px">
                <Stack.Item width="100%">
                  <Tabs height="37.5px">
                    {PAGES.map((page, i) => {
                      if (!page.canAccess(data)) {
                        return;
                      }
                      return (
                        <Tabs.Tab
                          key={i}
                          color={data.isxeno ? 'purple' : 'blue'}
                          width="100%"
                          selected={i === pageIndex}
                          icon={page.icon}
                          onClick={() =>
                            page.canOpen(data)
                              ? handleTacmapOnClick(i, page.title)
                              : null
                          }
                        >
                          {page.canOpen(data) ? page.title : 'loading'}
                        </Tabs.Tab>
                      );
                    })}
                  </Tabs>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <PageComponent fitted />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ViewMapPanel = (props) => {
  const { data, act } = useBackend<TacMapProps>();
  // DemonicLynx for BandaMarines - START: native live-map pan controls
  const [panX, setPanX] = useState(50);
  const [panY, setPanY] = useState(50);
  const mapViewportRef = useRef<HTMLDivElement>(null);

  const getNativeViewportSize = () => {
    const bounds = mapViewportRef.current?.getBoundingClientRect();
    const zoom = data.mapZoom ?? 2;
    const pixelRatio = window.devicePixelRatio || 1;

    return {
      viewportHeight: bounds
        ? Math.max(1, Math.floor((bounds.height * pixelRatio) / zoom))
        : undefined,
      viewportWidth: bounds
        ? Math.max(1, Math.floor((bounds.width * pixelRatio) / zoom))
        : undefined,
    };
  };

  useEffect(() => {
    act('panTacmap', {
      x: panX,
      y: panY,
      ...getNativeViewportSize(),
    });
  }, []);

  const updatePan = (axis: 'x' | 'y', value: number) => {
    if (axis === 'x') {
      setPanX(value);
    } else {
      setPanY(value);
    }
    act('panTacmap', {
      x: axis === 'x' ? value : panX,
      y: axis === 'y' ? value : panY,
      ...getNativeViewportSize(),
    });
  };
  // DemonicLynx for BandaMarines - END

  // byond ui can't resist trying to render
  if (!data.canViewTacmap || data.mapRef === null) {
    return <OldMapPanel {...props} />;
  }

  return (
    <Section fill>
      {/* DemonicLynx for BandaMarines - START: enlarged native map with two working scrollbars */}
      <div className="TacticalMapViewport">
        <div ref={mapViewportRef} className="TacticalMapViewport__map">
          <ByondUi
            height="100%"
            width="100%"
            params={{
              id: data.mapRef,
              type: 'map',
              'background-color': 'none',
              letterbox: false,
              zoom: data.mapZoom ?? 2,
              'zoom-mode': 'distort',
            }}
            className="TacticalMap"
          />
        </div>
        <input
          aria-label="Vertical tactical map position"
          className="TacticalMapViewport__slider TacticalMapViewport__slider--vertical"
          max={100}
          min={0}
          step={2}
          type="range"
          value={panY}
          onChange={(event) =>
            updatePan('y', Number(event.currentTarget.value))
          }
        />
        <input
          aria-label="Horizontal tactical map position"
          className="TacticalMapViewport__slider TacticalMapViewport__slider--horizontal"
          max={100}
          min={0}
          step={2}
          type="range"
          value={panX}
          onChange={(event) =>
            updatePan('x', Number(event.currentTarget.value))
          }
        />
        <div className="TacticalMapViewport__corner" />
      </div>
      {/* DemonicLynx for BandaMarines - END */}
    </Section>
  );
};

const OldMapPanel = (props) => {
  const { data } = useBackend<TacMapProps>();
  return (
    <Section fill align="center" fontSize="30px">
      {data.canViewCanvas ? (
        <DrawnMap
          svgData={data.svgData}
          flatImage={data.oldCanvasFlatImage}
          backupImage={data.mapFallback}
        />
      ) : (
        <Box my="40%">
          <h1>Unauthorized.</h1>
        </Box>
      )}
    </Section>
  );
};

const DrawMapPanel = (props) => {
  const { data, act } = useBackend<TacMapProps>();

  // DemonicLynx for BandaMarines - START: frontend pan state for the zoomed Canvas
  const [canvasPanX, setCanvasPanX] = useState(50);
  const [canvasPanY, setCanvasPanY] = useState(50);
  const canvasPanFromTop = 100 - canvasPanY;
  const canvasDisplaySize = TACTICAL_CANVAS_SIZE * TACTICAL_CANVAS_ZOOM;
  // DemonicLynx for BandaMarines - END

  const timeLeftPct = data.canvasCooldown / data.canvasCooldownDuration;
  const canUpdate = data.canvasCooldown <= 0 && !data.updatedCanvas;

  const handleTacMapExport = (image: any) => {
    data.exportedTacMapImage = image;
  };

  const handleColorSelection = (dataSelection: string) => {
    if (colors[dataSelection] !== null && colors[dataSelection] !== undefined) {
      return colors[dataSelection];
    } else {
      return dataSelection;
    }
  };
  const findColorValue = (oldValue: string) => {
    return (Object.keys(colors) as Array<string>).find(
      (key) => colors[key] === (oldValue as string),
    );
  };

  return (
    <Section fill>
      <Stack
        pl="5px"
        pr="5px"
        align="center"
        height="35px"
        className="BorederedStack"
      >
        <Stack.Item grow>
          {(!data.updatedCanvas && (
            <Button
              height="20px"
              fluid
              disabled={!canUpdate}
              color="red"
              icon="download"
              className="text-center"
              onClick={() => act('updateCanvas')}
            >
              Update Canvas
            </Button>
          )) || (
            <Button
              height="20px"
              fluid
              color="green"
              icon="bullhorn"
              className="text-center"
              onClick={() =>
                act('selectAnnouncement', {
                  image: data.exportedTacMapImage,
                })
              }
            >
              Announce
            </Button>
          )}
        </Stack.Item>
        <Stack.Item grow>
          <Button
            height="20px"
            fluid
            color="grey"
            icon="trash"
            className="text-center"
            onClick={() => act('clearCanvas')}
          >
            Clear Canvas
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            height="20px"
            fluid
            color="grey"
            icon="recycle"
            className="text-center"
            onClick={() => act('undoChange')}
          >
            Undo
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            className="TacticalMapColorPicker"
            menuWidth="15rem"
            options={colorOptions}
            selected={data.toolbarColorSelection}
            color={data.toolbarColorSelection}
            onSelected={(value) => act('selectColor', { color: value })}
            displayText={data.toolbarColorSelection}
          />
        </Stack.Item>
      </Stack>
      <Stack
        className={'progress-stack'}
        position="absolute"
        width="100%"
        style={{ zIndex: '1' }}
        bottom="-40px"
      >
        <Stack.Item grow>
          {data.canvasCooldown > 0 && (
            <ProgressBar
              height="20px"
              value={timeLeftPct}
              backgroundColor="rgba(0, 0, 0, 0.5)"
              ranges={{
                good: [-Infinity, 0.33],
                average: [0.33, 0.67],
                bad: [0.67, Infinity],
              }}
            >
              <Box textAlign="center" fontSize="15px" textColor="white">
                {Math.ceil(data.canvasCooldown / 10)} seconds until the canvas
                changes can be updated
              </Box>
            </ProgressBar>
          )}
        </Stack.Item>
      </Stack>
      {/* DemonicLynx for BandaMarines - START: zoomed Canvas with two pan sliders */}
      <div className="TacticalCanvasViewport">
        <div className="TacticalCanvasViewport__surface">
          <div
            className="TacticalCanvasViewport__content"
            style={{
              height: `${canvasDisplaySize}px`,
              left: `${canvasPanX}%`,
              top: `${canvasPanFromTop}%`,
              transform: `translate(-${canvasPanX}%, -${canvasPanFromTop}%)`,
              width: `${canvasDisplaySize}px`,
            }}
          >
            <CanvasLayer
              selection={handleColorSelection(data.toolbarUpdatedSelection)}
              actionQueueChange={data.actionQueueChange}
              displaySize={canvasDisplaySize}
              imageSrc={data.newCanvasFlatImage}
              key={data.lastUpdateTime}
              onImageExport={handleTacMapExport}
              onUndo={(value: string) =>
                act('selectColor', { color: findColorValue(value) })
              }
              onDraw={() => act('onDraw')}
            />
          </div>
        </div>
        <input
          aria-label="Vertical tactical canvas position"
          className="TacticalCanvasViewport__slider TacticalCanvasViewport__slider--vertical"
          max={100}
          min={0}
          step={2}
          type="range"
          value={canvasPanY}
          onChange={(event) => setCanvasPanY(Number(event.currentTarget.value))}
        />
        <input
          aria-label="Horizontal tactical canvas position"
          className="TacticalCanvasViewport__slider TacticalCanvasViewport__slider--horizontal"
          max={100}
          min={0}
          step={2}
          type="range"
          value={canvasPanX}
          onChange={(event) => setCanvasPanX(Number(event.currentTarget.value))}
        />
        <div className="TacticalCanvasViewport__corner" />
      </div>
      {/* DemonicLynx for BandaMarines - END */}
    </Section>
  );
};
