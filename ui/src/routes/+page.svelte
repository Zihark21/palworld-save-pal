<script lang="ts">
	import { getAppState } from '$states';
	import { goto } from '$app/navigation';

	const appState = getAppState();

	if (appState.saveFile) {
		goto('/edit');
	} else {
		goto('/file');
	}
</script>
