import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import ReanimatedSwipeable from 'react-native-gesture-handler/ReanimatedSwipeable';
import Reanimated, { SharedValue, useAnimatedStyle } from 'react-native-reanimated';
import Icon from './Icon';
import { colors, fonts, radii } from './theme';

interface Transaction {
  id: string;
  amount: number;
  type: 'expense' | 'income';
  category: {
    name: string;
    icon: string;
    color: string;
    bgColor: string;
    type: string;
  };
  note: string;
  paidBy: string;
  date: Date;
}

interface Props {
  transaction: Transaction;
  onDelete: (id: string) => void;
}

function formatDate(date: Date): string {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const txDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  const diff = today.getTime() - txDate.getTime();
  const days = diff / (1000 * 60 * 60 * 24);

  if (days === 0) return 'Today';
  if (days === 1) return 'Yesterday';
  return date.toLocaleDateString('en', { month: 'short', day: 'numeric' });
}

function RightAction({ drag }: { drag: SharedValue<number> }) {
  const animatedStyle = useAnimatedStyle(() => {
    const scale = Math.min(1, Math.max(0.5, -drag.value / 80));
    return { transform: [{ scale }] };
  });

  return (
    <View style={styles.deleteContainer}>
      <Reanimated.View style={animatedStyle}>
        <Icon name="Trash2" size={22} color={colors.white} />
      </Reanimated.View>
    </View>
  );
}

export default function TransactionRow({ transaction, onDelete }: Props) {
  const renderRightActions = (_progress: SharedValue<number>, drag: SharedValue<number>) => {
    return <RightAction drag={drag} />;
  };

  const { category, amount, paidBy, date, type } = transaction;
  const isIncome = type === 'income';
  const formattedAmount = `${isIncome ? '+' : '-'}€${amount.toFixed(2)}`;

  return (
    <ReanimatedSwipeable
      renderRightActions={renderRightActions}
      onSwipeableOpen={() => onDelete(transaction.id)}
      rightThreshold={80}
    >
      <View style={styles.row}>
        <View style={[styles.iconContainer, { backgroundColor: category.bgColor }]}>
          <Icon name={category.icon} size={20} color={category.color} />
        </View>
        <View style={styles.info}>
          <Text style={styles.name}>{category.name}</Text>
          <Text style={styles.sub}>{paidBy} · {formatDate(date)}</Text>
        </View>
        <Text style={[styles.amount, isIncome && { color: colors.green }]}>
          {formattedAmount}
        </Text>
      </View>
    </ReanimatedSwipeable>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.cardBg,
    borderRadius: radii.input,
    padding: 14,
    gap: 12,
  },
  iconContainer: {
    width: 40,
    height: 40,
    borderRadius: radii.iconContainer,
    justifyContent: 'center',
    alignItems: 'center',
  },
  info: {
    flex: 1,
    gap: 2,
  },
  name: {
    fontSize: 15,
    fontFamily: fonts.bodySemiBold,
    color: colors.dark,
  },
  sub: {
    fontSize: 12,
    fontFamily: fonts.bodyMedium,
    color: colors.muted,
  },
  amount: {
    fontSize: 15,
    fontFamily: fonts.bodyBold,
    color: colors.dark,
  },
  deleteContainer: {
    backgroundColor: colors.red,
    justifyContent: 'center',
    alignItems: 'center',
    width: 80,
    borderRadius: radii.input,
    marginLeft: 8,
  },
});
