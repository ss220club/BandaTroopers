import {
	createElement,
	useState,
	useBackend,
	Box,
	Button,
	NoticeBox,
	NumberInput,
	Section,
	Stack,
	Tabs,
	Window,
} from '../../../tgui/packages/tgui/humanAiPanelBridge';

type Field = {
	key: string;
	label: string;
	section: string;
	min: number;
	max: number;
	boolean?: number;
	integer?: number;
	value: number;
	help?: string;
};
type Data = {
	fields: Field[];
	alive: number;
	slots: { index: number; name: string | null }[];
	busy: number;
	status: string;
	revision: number;
	base_revision: number;
	dead: number;
	performance_profile?: {
		enabled: number;
		session: number;
		path: string | null;
		error: string | null;
	};
};

export const HumanAISettings = () => {
	const { data, act } = useBackend<Data>();
	const performanceProfile = data.performance_profile ?? {
		enabled: 0,
		session: 0,
		path: null,
		error: null,
	};
	const [section, setSection] = useState('Бой');
	const sections = [
		'Бой',
		'Преследование',
		'Гранаты',
		'Медицина',
		'Препятствия',
		'Снаряжение',
		'Движение',
		'Диагностика',
	];
	const disabled = !!data.busy;
	return (
		<Window width={1050} height={780} title="Human AI — настройки">
			<Window.Content scrollable>
				<NoticeBox>{data.status}</NoticeBox>
				<Section title="Область применения">
					<Box mt={1}>
						Общие настройки для всех живых и новых NPC. Мёртвые NPC
						исключены.
					</Box>
					<Box mt={1}>
						{(['easy', 'medium', 'hard'] as const).map(
							(level, index) => (
								<Button
									key={level}
									disabled={disabled}
									onClick={() => act('preset', { level })}
								>
									{['Лёгкая', 'Средняя', 'Сложная'][index]}
								</Button>
							),
						)}
						<Button
							disabled={disabled}
							icon="rotate"
							onClick={() => act('reload')}
						>
							Показать текущие настройки с сервера
						</Button>
						<Button
							icon="question-circle"
							tooltip="Загружает в панель настройки, которые сейчас действуют на сервере. Неприменённые изменения в черновике будут потеряны. Поведение NPC не меняется."
							aria-label="О загрузке текущих настроек"
						/>
					</Box>
					<Box color="label" mt={1}>
						Пресеты и личные слоты загружаются в черновик и требуют
						отдельного применения.
					</Box>
				</Section>
				<Section title="Личные конфигурации — 3 слота">
					{data.slots.map((slot) => (
						<Stack key={slot.index} align="center" mb={1}>
							<Stack.Item grow>
								{slot.index}. {slot.name || 'Пустой слот'}
							</Stack.Item>
							<Stack.Item>
								<Button
									disabled={disabled || !slot.name}
									onClick={() =>
										act('slot_load', { index: slot.index })
									}
								>
									Загрузить
								</Button>
							</Stack.Item>
							<Stack.Item>
								<Button
									disabled={disabled}
									onClick={() =>
										act('slot_save', { index: slot.index })
									}
								>
									Сохранить черновик
								</Button>
							</Stack.Item>
							<Stack.Item>
								<Button
									disabled={disabled || !slot.name}
									onClick={() =>
										act('slot_rename', {
											index: slot.index,
										})
									}
								>
									Название
								</Button>
							</Stack.Item>
							<Stack.Item>
								<Button
									color="bad"
									disabled={disabled || !slot.name}
									onClick={() =>
										act('slot_delete', {
											index: slot.index,
										})
									}
								>
									Удалить
								</Button>
							</Stack.Item>
						</Stack>
					))}
				</Section>
				<Tabs>
					{sections.map((name) => (
						<Tabs.Tab
							key={name}
							selected={section === name}
							onClick={() => setSection(name)}
						>
							{name}
						</Tabs.Tab>
					))}
				</Tabs>
				<Section title={section}>
					{section === 'Диагностика' ? (
						<Box>
							<Box mb={1}>
								<Button
									selected={!!performanceProfile.enabled}
									disabled={disabled || !data.performance_profile}
									onClick={() =>
										act('profile_set_enabled', {
											value: performanceProfile.enabled
												? 0
												: 1,
										})
									}
								>
									Диагностика нагрузки:{' '}
									{performanceProfile.enabled
										? 'Вкл'
										: 'Выкл'}
								</Button>
								<Button
									icon="question-circle"
									aria-label="О диагностике нагрузки"
									tooltip="Действует сразу для всего сервера, без применения черновика и изменения поведения NPC. Синхронные замеры включают вложенные вызовы: пересекающиеся строки нельзя складывать. Агрегированный CSV записывается каждые 10 секунд. Продолжения после ожиданий и работа снарядов сюда не входят. В личные слоты и настройки сервера не сохраняется; после перезапуска выключена."
								/>
							</Box>
							<Box color="label" mb={1}>
								{data.performance_profile
									? 'Переключается сразу; «Применить настройки» не требуется. После перезапуска выключена.'
									: 'Для диагностики запустите обновлённую сборку сервера.'}
							</Box>
							{performanceProfile.path && (
								<Box mb={1}>
									{performanceProfile.enabled
										? `Сеанс ${performanceProfile.session}. `
										: ''}
									CSV:{' '}
									{performanceProfile.path}
								</Box>
							)}
							{performanceProfile.error && (
								<NoticeBox danger>
									{performanceProfile.error}
								</NoticeBox>
							)}
							<Box>
								Живых NPC: {data.alive}. Исключено мёртвых:{' '}
								{data.dead}.
							</Box>
							<Box>
								Глобальная ревизия: {data.revision}. Ревизия
								черновика: {data.base_revision}.
							</Box>
							<Box mt={1}>
								Неотключаемые ограничения: проверка союзников
								при стрельбе, запас времени до взрыва, защита
								от передозировки, физическая проходимость и
								защита объектов.
								Безопасность гранат для союзников настраивается
								отдельно во вкладке «Гранаты».
							</Box>
							<Box mt={1}>
								Применения записываются в административный
								журнал. Сложность не даёт NPC видеть сквозь
								стены.
							</Box>
						</Box>
					) : (
						data.fields
							.filter((field) => field.section === section)
							.map((field) => (
								<Stack key={field.key} align="center" mb={1}>
									<Stack.Item grow>
										{field.label}{' '}
										{field.help && (
											<Button
												icon="question-circle"
												aria-label={`Описание: ${field.label}`}
												tooltip={`${field.help}${!field.boolean ? ` Допустимые значения: ${field.min}–${field.max}.` : ''}`}
											/>
										)}
									</Stack.Item>
									<Stack.Item>
										{field.boolean ? (
											<Button
												selected={!!field.value}
												disabled={disabled}
												onClick={() =>
													act('edit', {
														key: field.key,
														value: field.value
															? 0
															: 1,
													})
												}
											>
												{field.value
													? 'Включено'
													: 'Выключено'}
											</Button>
										) : (
											<NumberInput
												width={8}
												value={field.value}
												minValue={field.min}
												maxValue={field.max}
												step={field.integer ? 1 : 0.05}
												disabled={disabled}
												onChange={(value) =>
													act('edit', {
														key: field.key,
														value,
													})
												}
											/>
										)}
									</Stack.Item>
								</Stack>
							))
					)}
				</Section>

				{data.revision !== data.base_revision && (
					<NoticeBox warning>
						Глобальный профиль изменён. Загрузите действующие
						настройки перед применением.
					</NoticeBox>
				)}
				<Section title="Применение">
					<Button
						color="good"
						disabled={disabled}
						onClick={() => act('apply')}
					>
						Применить настройки
					</Button>

					<Button
						disabled={disabled}
						onClick={() => act('save_default')}
					>
						Сохранить для сервера после перезапуска
					</Button>
				</Section>
			</Window.Content>
		</Window>
	);
};
