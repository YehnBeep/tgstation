import { Feature, FeatureValueProps } from '../base';
import { Stack, TextArea } from '../../../../../components';

export const MultilineText = (
  props: FeatureValueProps<string, string> & { box_height: string | null }
) => {
  const { handleSetValue, value } = props;
  return (
    <Stack>
      <Stack.Item grow>
        <TextArea
          width="80%"
          height={props.box_height || '36px'}
          value={value}
          onInput={(e, value) => {
            handleSetValue(value);
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

export const flavor_text: Feature<string, string> = {
  name: 'Flavor - Flavor Text',
  component: (props: FeatureValueProps<string, string>, context) => {
    return <MultilineText {...props} box_height="52px" />;
  },
};

export const silicon_text: Feature<string, string> = {
  name: 'Flavor - Silicon Flavor Text',
  component: MultilineText,
};
