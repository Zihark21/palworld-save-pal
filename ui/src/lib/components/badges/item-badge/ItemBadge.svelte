<script lang="ts">
	import { Tooltip } from '$components/ui';
	import { type EggConfig, type ItemContainerSlot, type ItemGroup, Rarity } from '$types';
	import { ASSET_DATA_PATH } from '$lib/constants';
	import { itemsData, palsData } from '$lib/data';
	import { cn } from '$theme';
	import { getModalState } from '$states';
	import { ItemSelectModal } from '$components';
	import { Progress } from '@skeletonlabs/skeleton-svelte';
	import { Package } from 'lucide-svelte';
	import { assetLoader } from '$utils';
	import { staticIcons } from '$types/icons';

	let {
		slot = $bindable<ItemContainerSlot>(),
		itemGroup,
		onCopyPaste,
		onUpdate
	} = $props<{
		slot: ItemContainerSlot;
		itemGroup: ItemGroup;
		onCopyPaste?: (event: MouseEvent) => void;
		onUpdate?: (slot: ItemContainerSlot) => void;
	}>();

	const modal = getModalState();

	const stupidTypoMap: Record<string, string> = {
		cheeseburger_2: 'CheeseBurger_2',
		bone: 'Bone',
		potato: 'Potato',
		gunpowder: 'GunPowder',
		gunpowder2: 'GunPowder2',
		bow_triple: 'Bow_Triple'
	};

	const item = $derived.by(() => {
		if (slot.static_id == 'None') return;
		let key: string = slot.static_id;

		if (key.toLowerCase() in stupidTypoMap) {
			key = stupidTypoMap[key.toLowerCase()];
		}
		return itemsData.items[key];
	});

	const dynamic = $derived.by(() => {
		if (item) {
			return item.details.dynamic;
		}
	});

	const showDurability = $derived.by(() => {
		if (
			item?.details.type_a.toString() === 'Accessory' ||
			item?.details.type_a.toString() === 'Glider' ||
			item?.details.type_a.toString() === 'SphereModule' ||
			item?.details.type_b.toString() === 'WeaponGrapplingGun' ||
			item?.details.type_b.toString() === 'MaterialPalEgg'
		) {
			return false;
		}
		if (dynamic && dynamic.type === 'weapon' && slot.dynamic_item) {
			return true;
		}
		if (dynamic && dynamic.type === 'armor' && slot.dynamic_item) {
			return true;
		}
		return false;
	});

	const icon = $derived.by(() => {
		if (!item || !item.details.icon) {
			console.warn('Item icon not found:', item);
			return staticIcons.unknownIcon;
		}
		if (item && item.id.includes('SkillCard')) {
			return assetLoader.loadImage(`${ASSET_DATA_PATH}/img/${item.details.icon}.webp`);
		} else if (item) {
			return assetLoader.loadImage(`${ASSET_DATA_PATH}/img/${item.details.icon}.webp`);
		}
	});

	const slotWeight = $derived.by(() => {
		if (item?.details) {
			return (item.details.weight * slot.count).toFixed(1);
		} else {
			return 0;
		}
	});

	const itemClass = $derived.by(() => {
		switch (item?.details.rarity) {
			case Rarity.Uncommon:
				return 'bg-linear-to-tl from-green-500/50';
			case Rarity.Rare:
				return 'bg-linear-to-tl from-blue-500/50';
			case Rarity.Epic:
				return 'bg-linear-to-tl from-purple-500/50';
			case Rarity.Legendary:
				return 'bg-linear-to-tl from-yellow-500/50';
			default:
				return '';
		}
	});
	const itemPopupHeaderClass = $derived.by(() => {
		switch (item?.details.rarity) {
			case Rarity.Uncommon:
				return 'bg-linear-to-tl from-green-500/50 to-green-800/50 text-green-300 border-green-500';
			case Rarity.Rare:
				return 'bg-linear-to-tl from-blue-500/50 to-blue-800/50 text-blue-300 border-blue-500';
			case Rarity.Epic:
				return 'bg-linear-to-tl from-purple-500/50 to-purple-800/50 text-purple-300 border-purple-500';
			case Rarity.Legendary:
				return 'bg-linear-to-tl from-yellow-500/50 to-yellow-800/50 text-yellow-300 border-yellow-500';
			default:
				return 'bg-surface-800';
		}
	});

	const itemPopupTierClass = $derived.by(() => {
		switch (item?.details.rarity) {
			case Rarity.Uncommon:
				return 'bg-green-800 text-green-300 border-green-500';
			case Rarity.Rare:
				return 'bg-blue-800 text-blue-300 border-blue-500';
			case Rarity.Epic:
				return 'bg-purple-800 text-purple-300 border-purple-500';
			case Rarity.Legendary:
				return 'bg-yellow-800 text-yellow-300 border-yellow-500';
			default:
				return 'bg-surface-900 text-gray-300 border-gray-500';
		}
	});

	const palIcon = $derived.by(() => {
		if (slot.static_id && slot.static_id.includes('SkillUnlock_')) {
			const palCharacterId = slot.static_id.replace('SkillUnlock_', '');
			const palData = palsData.getPalData(palCharacterId);
			if (!palData) {
				console.error(`Pal data not found for static id: ${slot.static_id}`);
				return;
			}
			if (palData.disabled) {
				return staticIcons.unknownIcon;
			}
			const palImgName = palCharacterId.toLowerCase().replaceAll(' ', '_');
			return assetLoader.loadImage(`${ASSET_DATA_PATH}/img/t_${palImgName}_icon_normal.webp`);
		}
	});

	const isEgg = $derived.by(() => {
		return item?.details.dynamic?.type === 'egg';
	});
	const palIconSrc = $derived.by(() => {
		if (!isEgg) return;
		const palData = palsData.getPalData(slot?.dynamic_item?.character_id ?? '');
		return assetLoader.loadMenuImage(slot?.dynamic_item?.character_id, palData?.is_pal ?? true);
	});

	async function handleItemSelect() {
		// @ts-ignore
		const result = await modal.showModal<[string, number, EggConfig]>(ItemSelectModal, {
			group: itemGroup,
			itemId: slot.static_id,
			count: !slot.count || slot.count == 0 ? 1 : slot.count,
			title: 'Select Item',
			dynamicItem: slot.dynamic_item
		});
		if (!result) return;
		const [static_id, count, eggConfig] = result;
		slot.static_id = !static_id ? 'None' : static_id;
		if (slot.static_id == 'None') {
			slot.count = 0;
			slot.dynamic_item = undefined;
			return;
		}
		const itemData = itemsData.items[slot.static_id];
		if (itemData) {
			slot.count =
				count > itemData.details.max_stack_count ? itemData.details.max_stack_count : count;
			if (itemData.details.dynamic) {
				if (!slot.dynamic_item) {
					slot.dynamic_item = {
						local_id: '00000000-0000-0000-0000-000000000000'
					};
				}

				slot.dynamic_item.durability = itemData.details.dynamic.durability || 0;
				slot.dynamic_item.remaining_bullets = itemData.details.dynamic.magazine_size || 0;
				slot.dynamic_item.type = itemData.details.dynamic.type;
				slot.dynamic_item.static_id = static_id;

				if (slot.dynamic_item.type === 'egg') {
					slot.dynamic_item.character_id = eggConfig.character_id;
					slot.dynamic_item.gender = eggConfig.gender;
					slot.dynamic_item.talent_hp = eggConfig.talent_hp;
					slot.dynamic_item.talent_shot = eggConfig.talent_shot;
					slot.dynamic_item.talent_defense = eggConfig.talent_defense;
					slot.dynamic_item.active_skills = eggConfig.active_skills;
					slot.dynamic_item.learned_skills = eggConfig.learned_skills;
					slot.dynamic_item.passive_skills = eggConfig.passive_skills;
					slot.dynamic_item.modified = true;
				}
			} else {
				slot.dynamic_item = undefined;
			}
		}
		if (onUpdate) onUpdate(slot);
	}

	function handleMouseEvent(
		event: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement }
	) {
		onCopyPaste(event);
	}
</script>

<button
	class="hover:ring-secondary-500 w-12 hover:ring xl:w-16"
	onclick={handleItemSelect}
	oncontextmenu={(event) => event.preventDefault()}
	onmousedown={(event) => handleMouseEvent(event)}
>
	{#if item}
		<Tooltip
			popupClass="p-0 mt-12 bg-surface-600"
			rounded="rounded-none"
			position="right"
			useArrow={false}
		>
			<div class="flex flex-col">
				<div
					class={cn(
						'bg-surface-800/50 relative flex h-12 w-12 items-center justify-center xl:h-16 xl:w-16',
						itemClass
					)}
				>
					<span class="absolute left-0.5 top-0 text-xs">{slotWeight}</span>
					<img src={icon} alt={item.info.localized_name} class="h-12 w-12 xl:h-16 xl:w-16" />
					{#if palIcon}
						<div class="bg-surface-800 border-surface-600 absolute right-0 top-0 h-7 w-7 border">
							<img src={palIcon} alt="Pal Icon" class="h-full w-full object-cover" />
						</div>
					{/if}

					{#if slot.count}
						<span class="absolute bottom-0 right-0.5 text-xs">{slot.count}</span>
					{/if}
				</div>
				{#if showDurability && dynamic}
					<Progress
						value={slot.dynamic_item.durability}
						max={dynamic.durability < slot.dynamic_item.durability
							? slot.dynamic_item.durability
							: dynamic.durability}
						height="h-1"
					/>
				{/if}
			</div>

			{#snippet popup()}
				<div class="flex w-96 flex-col">
					<div class={cn('flex flex-col space-y-2 border-b p-2', itemPopupHeaderClass)}>
						<div class="flex items-center space-x-2">
							<h4 class="h4 text-left">{item?.info.localized_name}</h4>
							{#if isEgg}
								<img
									src={palIconSrc}
									alt="Pal Icon"
									class="ml-2 h-10 w-10 rounded-full object-cover"
								/>
							{/if}
						</div>
						<div class="grid grid-cols-[1fr_auto] gap-2">
							<span class="grow text-left text-gray-300">
								{item?.details.type_a}
							</span>
							<div
								class={cn(
									'border-l border-r p-2 px-2 py-0.5 text-left text-sm font-bold',
									itemPopupTierClass
								)}
							>
								{item?.details.rarity !== undefined ? Rarity[item.details.rarity] : ''}
							</div>
						</div>
					</div>
					<div class="relative flex flex-row">
						<div class="m-4 ml-8">
							<img
								src={icon}
								alt={item?.info.localized_name}
								style="width: 112px; height: 112px;"
							/>
						</div>
						<div
							class="bg-surface-800 text-one-surface hover:ring-secondary-500 absolute bottom-4 right-4 rounded-sm px-3 py-1 font-semibold hover:ring"
							style="min-width: 80px; height: 2rem;"
						>
							<div class="relative z-10 flex h-full items-center justify-between">
								<span class="mr-8 text-xs">in inventory</span>
								<span class="font-bold">{slot.count}</span>
							</div>
							<span class="border-surface-700 absolute inset-0 rounded-sm border"></span>
							<span class="bg-surface-400 absolute left-0 top-0 h-0.5 w-0.5"></span>
							<span class="bg-surface-400 absolute right-0 top-0 h-0.5 w-0.5"></span>
							<span class="bg-surface-400 absolute bottom-0 left-0 h-0.5 w-0.5"></span>
							<span class="bg-surface-400 absolute bottom-0 right-0 h-0.5 w-0.5"></span>
						</div>
					</div>
					<div class="bg-surface-900 p-2 text-left">
						<span class="whitespace-pre-line">{item?.info.description}</span>
					</div>
					<div class="bg-surface-900 flex p-2 text-sm">
						<div class="flex grow flex-col space-y-2">
							<div class="flex items-center space-x-2">
								<div class="h-6 w-6">
									<img src={staticIcons.rightClickIcon} alt="Right Click" class="h-full w-full" />
								</div>
								<span class="text-xs font-bold">Copy</span>
							</div>
							<div class="flex items-center space-x-2">
								<div class="h-6 w-6">
									<img src={staticIcons.ctrlIcon} alt="Right Click" class="h-full w-full" />
								</div>
								<div class="h-6 w-6">
									<img src={staticIcons.rightClickIcon} alt="Right Click" class="h-full w-full" />
								</div>
								<span class="text-xs font-bold">Paste</span>
							</div>
							<div class="flex items-center space-x-2">
								<div class="h-6 w-6">
									<img src={staticIcons.ctrlIcon} alt="Right Click" class="h-full w-full" />
								</div>
								<div class="h-6 w-6">
									<img src={staticIcons.middleClickIcon} alt="Right Click" class="h-full w-full" />
								</div>
								<span class="text-xs font-bold">Delete</span>
							</div>
						</div>
						<div
							class="bg-surface-800 text-one-surface hover:ring-secondary-500 absolute bottom-4 right-4 rounded-sm px-3 py-1 font-semibold hover:ring"
							style="min-width: 80px; height: 2rem;"
						>
							<div class="relative z-10 flex h-full items-center justify-between">
								<div class="h-6 w-6">
									<img src={staticIcons.weightIcon} alt="Weight" class="h-full w-full" />
								</div>
								<span class="font-bold">{slotWeight}</span>
							</div>
							<span class="border-surface-700 absolute inset-0 rounded-sm border"></span>
							<span class="bg-surface-400 absolute left-0 top-0 h-0.5 w-0.5"></span>
							<span class="bg-surface-400 absolute right-0 top-0 h-0.5 w-0.5"></span>
							<span class="bg-surface-400 absolute bottom-0 left-0 h-0.5 w-0.5"></span>
							<span class="bg-surface-400 absolute bottom-0 right-0 h-0.5 w-0.5"></span>
						</div>
					</div>
				</div>
			{/snippet}
		</Tooltip>
	{:else if slot.static_id !== 'None'}
		<Tooltip>
			<div
				class="bg-surface-800 relative flex h-12 w-12 items-center justify-center xl:h-16 xl:w-16"
			>
				<Package size="48" />
				<span class="absolute bottom-0 right-0 text-xs">{slot.count}</span>
			</div>

			{#snippet popup()}
				<span>{slot.static_id}</span>
			{/snippet}
		</Tooltip>
	{:else}
		<Tooltip>
			<div
				class="bg-surface-800 relative flex h-12 w-12 items-center justify-center xl:h-16 xl:w-16"
			></div>

			{#snippet popup()}
				<div class="flex">
					<span>Empty </span>
					<img src={staticIcons.sadIcon} alt="Sad Icon" class="h-6 w-6" />
				</div>
			{/snippet}
		</Tooltip>
	{/if}
</button>
